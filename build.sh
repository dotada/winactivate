#!/bin/bash

set -e

function get_cab_url() {
    echo -n 'https://download.microsoft.com/download/9/A/E/9AE69DD5-BA93-44E0-864E-180F5E700AB4/adk/Installers/'"$1"'.cab'
}

./clean.sh
echo

echo "Verifying if dependencies are satisfied... "
unsatisfied=false
for x in \
    aarch64-w64-mingw32-clang aarch64-w64-mingw32-strip i686-w64-mingw32-clang i686-w64-mingw32-strip \
    7z curl
do
    set +e # Failure is acceptable in this case
    if ! which "$x" 2>/dev/null >/dev/null; then
        [ "$unsatisfied" == "false" ] && unsatisfied=""
        unsatisfied="$x $unsatisfied"
    else
        echo "OK $x"
    fi
done
set -e # Restore original behavior
if [ "$unsatisfied" != 'false' ]; then
    echo
    echo "FAILED! The following dependencies are not satisfied:"
    for x in $unsatisfied
    do
        echo "  $x"
    done
    echo
    echo "HINT:"
    echo
    echo "For LLVM related dependenices:"
    echo "  Check https://github.com/mstorsjo/llvm-mingw/releases and"
    echo "  download the ubuntu tarball (even if you're not using Ubuntu)"
    echo "  Afterwards extract it and add the bin folder to your PATH."
    echo
    echo "For 7z related dependencies:"
    echo "  Install 7z from your package manager or download it from"
    echo "  https://www.7-zip.org/download.html"
    echo
    echo "For curl related dependencies:"
    echo "  Install curl from your package manager"
    exit 1
else
    echo "Done!"
fi

echo
echo "Building Integrated_Patcher_3..."
pushd third_party/Integrated_Patcher_3 >/dev/null
make slshim32_akai.dll slshimARM64_akai.dll
mv slshim32_akai.dll ../../bin/slc.dll
mv slshimARM64_akai.dll ../../bin/arm64_slc.dll
echo "Done!"
popd >/dev/null

echo
echo "Getting gatherosstate.exe from Microsoft download servers..."
echo "This may take a while..."
tempdir=$(mktemp -d)
echo "Downloading to $tempdir..."
pushd "$tempdir" >/dev/null
curl -L -O "$(get_cab_url 14f4df8a2a7fc82a4f415cf6a341415d)" # x86
curl -L -O "$(get_cab_url 2e82f679c8709f838e7c839f7864ac84)" # arm64
7z x 14f4df8a2a7fc82a4f415cf6a341415d.cab filf8377e82b29deadca67bc4858ed3fba9
mv filf8377e82b29deadca67bc4858ed3fba9 gatherosstate.exe
7z x 2e82f679c8709f838e7c839f7864ac84.cab fil5b1b0ad2f49ecc0bc53f4104512ad200
mv fil5b1b0ad2f49ecc0bc53f4104512ad200 arm64_gatherosstate.exe
popd >/dev/null
mv "$tempdir/gatherosstate.exe" bin/
mv "$tempdir/arm64_gatherosstate.exe" bin/
rm -rf "$tempdir"
echo "Done!"
