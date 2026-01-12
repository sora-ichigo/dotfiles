# Nix package manager (Determinate Systems installer)
# https://github.com/DeterminateSystems/nix-installer

nix_bin = "/nix/var/nix/profiles/default/bin/nix"

execute "install nix" do
  command "curl --proto '=https' --tlsv1.2 -sSf -L https://install.determinate.systems/nix | sh -s -- install --no-confirm"
  not_if "test -x #{nix_bin}"
end
