# Homebrew formula for ghh
# Host this file in a separate repo: jgorodetsky/homebrew-ghh
# Then users can: brew tap jgorodetsky/ghh && brew install ghh

class Ghh < Formula
  desc "Your entire git + GitHub workflow in one searchable command"
  homepage "https://github.com/jgorodetsky/ghh"
  url "https://github.com/jgorodetsky/ghh/archive/refs/tags/v0.3.0.tar.gz"
  sha256 "83b8d781b24dc3d3254d497b6b9720494f4ea9ac0a56efda7b2312661c0a0287"
  license "MIT"

  depends_on "fzf"

  def install
    bin.install "bin/ghh"
  end

  def caveats
    <<~EOS
      To activate ghh, add this to your shell config (~/.zshrc or ~/.bashrc):

        source $(brew --prefix)/bin/ghh

      Then restart your shell and type: ghh
    EOS
  end

  test do
    output = shell_output("source #{bin}/ghh && ghh-version")
    assert_match "ghh", output
  end
end
