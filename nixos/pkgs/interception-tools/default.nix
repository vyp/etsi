with import <nixpkgs> {};

let
  libyamlcppWithoutBoost = libyamlcpp.overrideAttrs (oldAttrs: rec {
    name = "libyaml-cpp-${version}";
    version = "2017-07-25";

    src = fetchFromGitHub {
      owner = "jbeder";
      repo = "yaml-cpp";
      rev = "e2818c423e5058a02f46ce2e519a82742a8ccac9";
      sha256 = "0v2b0lxysxncqnm4k9by815a6w72k3f1fpprsnw46pwiv3id54cb";
    };

    buildInputs = [ cmake ];
  });

  version = "0.1.0";
  baseName = "interception-tools";
in stdenv.mkDerivation {
  name = "${baseName}-${version}";

  src = fetchurl {
    url = "https://gitlab.com/interception/linux/tools/repository/v${version}/archive.tar.gz";
    sha256 = "0xyr7w2r5bcy1kmfqlbw7c9rvi7ia9lcsa3851dpm1k99hf523vr";
  };

  nativeBuildInputs = [ pkgconfig ];
  buildInputs = [ cmake libevdev libudev libyamlcppWithoutBoost ];

  prePatch = ''
    sed -i 's/"\/usr\/include\/libevdev-1.0"/"'\
    "$(pkg-config --cflags libevdev \
    | cut -c 3- \
    | sed 's/\//\\\//g')"'"/g' \
    CMakeLists.txt
  '';

  patches = [ ./0001-remove-some-BUS-stuff.patch ];

  meta = {
    homepage = "https://gitlab.com/interception/linux/tools";
    description = "A minimal composable infrastructure on top of libudev and libevdev";
    license = stdenv.lib.licenses.gpl3;
    platforms = stdenv.lib.platforms.linux;
  };
}