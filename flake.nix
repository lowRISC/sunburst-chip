# Copyright lowRISC contributors.
# Licensed under the Apache License, Version 2.0, see LICENSE for details.
# SPDX-License-Identifier: Apache-2.0
{
  description = "Sunburst Chip";
  inputs = {
    # Standard packages
    lowrisc-nix.url = "github:lowRISC/lowrisc-nix";
    nixpkgs.follows = "lowrisc-nix/nixpkgs";
    flake-utils.follows = "lowrisc-nix/flake-utils";

    # Python environment
    pyproject-nix = {
      url = "github:pyproject-nix/pyproject.nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    uv2nix = {
      url = "github:pyproject-nix/uv2nix";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
    pyproject-build-systems = {
      url = "github:pyproject-nix/build-system-pkgs";
      inputs.pyproject-nix.follows = "pyproject-nix";
      inputs.uv2nix.follows = "uv2nix";
      inputs.nixpkgs.follows = "nixpkgs";
    };
  };

  nixConfig = {
    extra-substituters = ["https://nix-cache.lowrisc.org/public/"];
    extra-trusted-public-keys = ["nix-cache.lowrisc.org-public-1:O6JLD0yXzaJDPiQW1meVu32JIDViuaPtGDfjlOopU7o="];
  };

  outputs = {
    self,
    nixpkgs,
    flake-utils,
    pyproject-nix,
    pyproject-build-systems,
    uv2nix,
    lowrisc-nix,
    ...
  } @ inputs: let
    system_outputs = system: let
      pkgs = import nixpkgs {inherit system;};
      lrDoc = lowrisc-nix.lib.doc {inherit pkgs;};
      lrPkgs = lowrisc-nix.outputs.packages.${system};
      inherit (pkgs.lib) fileset getExe;
      inherit (nixpkgs) lib;

      workspace = inputs.uv2nix.lib.workspace.loadWorkspace {workspaceRoot = ./.;};

      overlay = workspace.mkPyprojectOverlay {
        sourcePreference = "wheel"; # or sourcePreference = "sdist";
      };

      pyprojectOverrides = _final: _prev: {
      };

      pythonSet =
        # Use base package set from pyproject.nix builders
        (pkgs.callPackage pyproject-nix.build.packages {
          python = pkgs.python310;
        }).overrideScope
          (
            lib.composeManyExtensions [
              pyproject-build-systems.overlays.default
              overlay
              (lowrisc-nix.lib.pyprojectOverrides {inherit pkgs;})
              pyprojectOverrides
            ]
          );

      pythonEnv = pythonSet.mkVirtualEnv "sunburst-chip-env" workspace.deps.default;

      cheriotPkgs = lowrisc-nix.outputs.devShells.${system}.cheriot.nativeBuildInputs;

      sunburst_simulator_source = fileset.toSource {
        root = ./.;
        fileset = fileset.unions [
          ./hw
        ];
      };

      sunburst_simulator = pkgs.stdenv.mkDerivation rec {
        name = "sunburst_simulator";
        src = sunburst_simulator_source;
        buildInputs = with pkgs; [libelf zlib];
        nativeBuildInputs = [pkgs.verilator pythonEnv];
        buildPhase = ''
          HOME=$TMPDIR fusesoc --cores-root=. run \
            --target=sim --setup --build lowrisc:sunburst:top_chip_verilator \
            --verilator_options="-j $NIX_BUILD_CORES" --make_options="-j $NIX_BUILD_CORES"
        '';
        installPhase = ''
          mkdir -p $out/bin/
          cp -r build/lowrisc_sunburst_top_chip_verilator_0/sim-verilator/Vtop_chip_verilator $out/bin/${name}
        '';
        meta.mainProgram = name;
      };

      sunburst_device_software = pkgs.stdenv.mkDerivation rec {
        name = "sunburst_device_software";
        src = fileset.toSource {
          root = ./.;
          fileset = fileset.unions [
            ./sw/device
            ./hw/top_chip/sw/autogen
            ./util/extract_sw_logs.py
          ];
        };
        sourceRoot = "${src.name}/sw/device";
        nativeBuildInputs = [cheriotPkgs pythonEnv pkgs.cmake];
        dontFixup = true;
      };

      # Baremetal software dependencies
      cheriotRtosSource = pkgs.fetchFromGitHub {
        owner = "CHERIoT-Platform";
        repo = "CHERIoT-RTOS";
        rev = "64d846091a43053fbdd0312fb9419e05429109c6";
        fetchSubmodules = true;
        hash = "sha256-mtsmJ4mY+b7Jm244Rn3nEfmwX4cy2dzeoXNY5yvXHpo=";
      };
      reisfmtSource = pkgs.fetchFromGitHub {
        owner = "engdoreis";
        repo = "reisfmt";
        rev = "4ce04e1bc88d37ad359da051b91b4071f740c3d8";
        fetchSubmodules = true;
        hash = "sha256-sj4nyevLiCSEQk5KW8wea0rgAnI2quOi1h71dU+QYpU=";
      };

      sunburst_baremetal_software = pkgs.stdenv.mkDerivation rec {
        name = "sunburst_baremetal_software";
        src = fileset.toSource {
          root = ./.;
          fileset = fileset.unions [
            ./scratch_sw/bare_metal
          ];
        };
        sourceRoot = "${src.name}/scratch_sw/bare_metal";
        nativeBuildInputs = cheriotPkgs ++ (with pkgs; [cmake git]);
        cmakeFlags = [
          "-DFETCHCONTENT_SOURCE_DIR_CHERIOT_RTOS=${cheriotRtosSource}"
          "-DFETCHCONTENT_SOURCE_DIR_REISFMT=${reisfmtSource}"
        ];
        dontFixup = true;
      };

      test_simulator = pkgs.stdenvNoCC.mkDerivation {
        name = "test_simulator";
        src = fileset.toSource {
          root = ./.; # an empty source directory
          fileset = fileset.unions [];
        };
        dontBuild = true;
        doCheck = true;
        buildInputs = [sunburst_simulator];
        checkPhase = ''
          set -e
          sunburst_simulator -E ${sunburst_device_software}/bin/usbdev_vbus_test
          echo "USB smoke complete!"
          sunburst_simulator -E ${sunburst_baremetal_software}/bin/chip_check
          echo "Chip check complete!"
        '';
        installPhase = "mkdir $out";
      };
    in {
      formatter = pkgs.alejandra;
      packages = {
        inherit
          sunburst_simulator
          cheriotPkgs
          sunburst_device_software
          sunburst_baremetal_software
          test_simulator
          ;
      };
    };
  in
    flake-utils.lib.eachDefaultSystem system_outputs;
}
