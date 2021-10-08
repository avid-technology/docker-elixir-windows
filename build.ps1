param (
  $from_image_repo="ghcr.io",
  $from_image_name="avid-technology/erlang",
  $from_image_tag="24.0.6-windows-servercore-1809",

  $build_image_repo="ghcr.io",
  $build_image_name="avid-technology/erlang",
  $build_image_tag="24.0.6-windows-servercore-1809",

  $otp_version="24.0.6",

  $elixir_version="1.12.2",
  $elixir_hash="38eb2281032b0cb096ef5e61f048c5374d6fb9bf4078ab8f9526a42e16e7c661732a632b55d6072328eedf87a47e6eeb3f0e3f90bba1086239c71350f90c75e5",

  $repo="elixir"
)

$from_image = "${from_image_repo}/${from_image_name}:${from_image_tag}"
$build_image = "${build_image_repo}/${build_image_name}:${build_image_tag}"

$elixir_tag = @($elixir_version, "erlang", $from_image_tag) -join "-"
$tag = "${repo}:${elixir_tag}"

docker build `
  --cache-from $tag `
  --build-arg "ELIXIR_VERSION=$elixir_version" `
  --build-arg "ELIXIR_HASH=$elixir_hash" `
  --build-arg "FROM_IMAGE=$from_image" `
  --build-arg "BUILD_IMAGE=$build_image" `
  --build-arg "OTP_VERSION=$otp_version" `
  -t $tag `
  .

If ($Env:CI -eq "true") {
  docker push $tag
}
