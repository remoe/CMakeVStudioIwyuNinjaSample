del /S /Q .build
cmake -GNinja -B.build .
ninja -C .build
