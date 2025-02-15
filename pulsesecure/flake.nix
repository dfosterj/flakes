  {
  description = "Setup a VPN connection using pulse-cookie with openconnect integration";

  inputs = {
    nixpkgs.url = "github:NixOS/nixpkgs/nixos-24.05";
    flake-utils.url = "github:numtide/flake-utils";
  };

  outputs = { self, nixpkgs, flake-utils }:
    flake-utils.lib.eachSystem [ "x86_64-linux" ] (system:
      let
        pkgs = import nixpkgs {
          inherit system;
          config = { allowUnfree = true; };
        };

        pulse-cookie = pkgs.python3.pkgs.buildPythonApplication rec {
          pname = "pulse-cookie";
          version = "1.0";

          src = pkgs.fetchPypi {
            inherit pname version;
            sha256 = "sha256-ZURSXfChq2k8ktKO6nc6AuVaAMS3eOcFkiKahpq4ebU=";
          };

          propagatedBuildInputs = [
            pkgs.python3.pkgs.pyqt6
            pkgs.python3.pkgs.pyqt6-webengine
            pkgs.python3.pkgs.setuptools
            pkgs.python3.pkgs.setuptools_scm
          ];

          preBuild = ''
            cat > setup.py << EOF
            from setuptools import setup

            setup(
              name='pulse-cookie',
              packages=['pulse_cookie'],
              package_dir={"": 'src'},
              version='1.0',
              author='Raj Magesh Gauthaman',
              description='wrapper around openconnect allowing user to log in through a webkit window for mfa',
              install_requires=[
                'PyQt6-WebEngine',
              ],
              entry_points={
                'console_scripts': ['get-pulse-cookie=pulse_cookie._cli:main']
              },
            )
            EOF
          '';

          meta = with pkgs.lib; {
            homepage = "https://pypi.org/project/pulse-cookie/";
            description = "wrapper around openconnect allowing user to log in through a webkit window for mfa";
            license = licenses.gpl3;
          };
        };

        start-pulse-vpn = pkgs.writeShellScriptBin "start-pulse-vpn" ''
          HOST=https://secure.med.harvard.edu
          DSID=$(${pulse-cookie}/bin/get-pulse-cookie -n DSID $HOST)
          sudo ${pkgs.openconnect}/bin/openconnect --protocol nc -C DSID=$DSID $HOST
        '';

      in {
        devShell = pkgs.mkShell {
          name = "pulse-vpn-env";

          buildInputs = [
            pkgs.openconnect
            pulse-cookie
            start-pulse-vpn
          ];

          shellHook = ''
            echo "Pulse VPN environment ready."
          '';
        };
      });
}
