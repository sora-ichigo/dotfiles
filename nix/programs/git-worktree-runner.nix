{ pkgs, ... }:

let
  git-worktree-runner = pkgs.stdenv.mkDerivation {
    pname = "git-worktree-runner";
    version = "unstable-2025-01-07";

    src = pkgs.fetchFromGitHub {
      owner = "coderabbitai";
      repo = "git-worktree-runner";
      rev = "7a315d7091a0f18cd96a1fd0b4767b93f4f95991";
      hash = "sha256-JVBngE93Kz/DTbptB70IPOU87RgyJWnYFkTkJno1C9Q=";
    };

    installPhase = ''
      mkdir -p $out/share/git-worktree-runner
      cp -r bin lib adapters templates $out/share/git-worktree-runner/

      mkdir -p $out/bin
      cat > $out/bin/gtr <<EOF
#!/usr/bin/env bash
export GTR_DIR="$out/share/git-worktree-runner"
exec "$out/share/git-worktree-runner/bin/gtr" "\$@"
EOF
      chmod +x $out/bin/gtr

      cat > $out/bin/git-gtr <<EOF
#!/usr/bin/env bash
export GTR_DIR="$out/share/git-worktree-runner"
exec "$out/share/git-worktree-runner/bin/gtr" "\$@"
EOF
      chmod +x $out/bin/git-gtr
    '';

    meta = with pkgs.lib; {
      description = "Bash-based Git worktree manager with editor and AI tool integration";
      homepage = "https://github.com/coderabbitai/git-worktree-runner";
      license = licenses.asl20;
    };
  };
in
{
  home.packages = [ git-worktree-runner ];

  home.file.".local/bin/git-worktree-runner-ai" = {
    executable = true;
    text = ''
      #!/usr/bin/env bash
      exec claude "$@"
    '';
  };
}
