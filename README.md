# Python GDAL lambda layer
A build pipeline for creating a lambda layer with GDAL and the python bindings
installed. Ready-to-use zip packages are available on each release.

Create a layer from the desired release artifact and attach the layer to your
lambda function:
```terraform
resource "aws_lambda_layer_version" "gdal_lambda_layer" {
  layer_name = "gdal-lambda-layer"

  filename         = "lambda-gdal3.6-python3.9-2023.9.27.zip"
  source_code_hash = filebase64sha256("lambda-gdal3.6-python3.9-2023.9.27.zip")

  compatible_architectures = ["x86_64"]
  compatible_runtimes      = ["python3.9"]
}

resource "aws_lambda_function" "gdal_lambda_function" {
  function_name = "gdal-lambda-function"

  # ... Function code configuration ...

  environment {
    variables = {
      # https://github.com/lambgeo/docker-lambda/issues/56
      LD_PRELOAD = "/opt/lib/libsqlite3.so"
    }
  }

  layers  = [aws_lambda_layer_version.gdal_lambda_layer.arn]
  runtime = "python3.9"
}
```

GDAL can then be imported from python in the lambda code:

```python
from osgeo import gdal
```

## Known issues
There is a known issue with the python sqlite3 version being older than the
minimum supported version required by the PROJ library. This lambda layer ships
with a newer version of sqlite3, however, due to how the python sqlite3 module
is compiled, it will not be picked up automatically. To force the dynamic
linker to pick up the version of sqlite3 packaged with this lambda you need to
add `LD_PRELOAD=/opt/lib/libsqlite3.so` to the lambda environment variables.

See also: https://github.com/lambgeo/docker-lambda/issues/56
