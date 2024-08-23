{ lib, buildGoModule, fetchFromGitHub, go-mockery, runCommand, go }:

buildGoModule rec {
  pname = "go-mockery";
  version = "2.44.2";

  src = fetchFromGitHub {
    owner = "vektra";
    repo = "mockery";
    rev = "v${version}";
    sha256 = "sha256-zVzCAX52kzugj9LRqnrUZ881sE8EyhLM1QPnJK5O2ak=";
  };

  preCheck = ''
    substituteInPlace ./pkg/generator_test.go --replace-fail 0.0.0-dev ${version}
    substituteInPlace ./pkg/logging/logging_test.go --replace-fail v0.0 v${lib.versions.majorMinor version}
  '';

  ldflags = [
    "-s" "-w"
    "-X" "github.com/vektra/mockery/v2/pkg/logging.SemVer=v${version}"
  ];

  CGO_ENABLED = false;

  proxyVendor = true;
  vendorHash = "sha256-1SzdVM1Ncpym6bPg1aSyfoAM1YiUGal3Glw0paz+buk=";

  subPackages = [ "." ];

  passthru.tests = {
    generateMock = runCommand "${pname}-test" {
      nativeBuildInputs = [ go-mockery ];
      buildInputs = [ go ];
    } ''
      if [[ $(mockery --version) != *"${version}"* ]]; then
        echo "Error: program version does not match package version"
        exit 1
      fi

      export HOME=$TMPDIR

      cat <<EOF > foo.go
      package main

      type Foo interface {
        Bark() string
      }
      EOF

      mockery --name Foo --dir .

      if [[ ! -f "mocks/Foo.go" ]]; then
        echo "Error: mocks/Foo.go was not generated by ${pname}"
        exit 1
      fi

      touch $out
    '';
  };

  meta = with lib; {
    homepage = "https://github.com/vektra/mockery";
    description = "Mock code autogenerator for Golang";
    maintainers = with maintainers; [ fbrs ];
    mainProgram = "mockery";
    license = licenses.bsd3;
  };
}
