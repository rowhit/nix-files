with import <nixpkgs> { };

## Example

# nix-build \
#   --argstr name "laas" \
#   --argstr src laas_1.3.2_linux_amd64.tar.gz \
#   --argstr entrypoint "/laas_1.3.2_linux_amd64/laas" \
#   dockerise-tar.nix

# docker load -i result

# docker run -v ~/:/root -ti laas service list

let
  alpine = dockerTools.buildImage {
    name = "alpine";
    runAsRoot = ''
      mkdir /lib64 && ln -s /lib/libc.musl-x86_64.so.1 /lib64/ld-linux-x86-64.so.2
      echo "hosts: files dns myhostname mymachines" > /etc/nsswitch.conf
      ln -s /etc/ssl/certs/ca-bundle.crt /etc/ssl/certs/ca-certificates.crt
    '';
    fromImage = dockerTools.buildImage {
      name = "alpine";
      contents = cacert;
      fromImage = dockerTools.pullImage {
        imageName = "alpine";
        imageTag = "3.3";
        imageId = "f58d61a874bedb7cdcb5a409ebb0c53b0656b880695c14e78a69902873358d5f";
        sha256 = "0lvd5zxjgwp3jl5r8qgb2kapmxclpgdv1a7c03yiagxsil5gwb8c";
      };
    };
  };
in
{ name, src, entrypoint }:
dockerTools.buildImage {
  inherit name;
  fromImage = alpine;
  contents = runCommand "${name}-src" { } ''
    mkdir -p $out
    cd $out
    tar xf ${src}
  '';
  config = {
    Entrypoint = [ entrypoint ];
  };
}

