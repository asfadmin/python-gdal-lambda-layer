#!/bin/bash
echo "-----------------------"
echo "Creating lambda layer"
echo "-----------------------"

echo "Install python bindings"
GDAL_VERSION=$(gdal-config --version)
pip install "gdal==$GDAL_VERSION" --no-binary :all: -t /tmp/python

echo "Remove useless files"
rm -rdf $PREFIX/share/doc \
&& rm -rdf $PREFIX/share/man \
&& rm -rdf $PREFIX/share/cryptopp \
&& rm -rdf $PREFIX/share/hdf*

echo "Strip shared libraries"
cd $PREFIX && find lib/ -type f -name \*.so\* -exec strip {} \;

echo "Create archives"
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip lib/*.so*
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip share
cd $PREFIX && zip -r9q --symlinks /tmp/package.zip bin/gdal* bin/ogr* bin/geos* bin/nearblack bin/postgres bin/pg_* bin/proj*
cd /tmp && zip -r9q --symlinks /tmp/package.zip python
