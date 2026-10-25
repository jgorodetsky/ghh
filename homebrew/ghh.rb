# Homebrew formula for ghh
# Host this file in a separate repo: jgorodetsky/homebrew-ghh
# Then users can: brew tap jgorodetsky/ghh && brew install ghh

class Ghh < Formula
  desc "Your entire git + GitHub workflow in one searchable command"
  homepage "https://github.com/jgorodetsky/ghh"
  url "https://github.com/jgorodetsky/ghh/archive/refs/tags/v0.5.1.tar.gz"
  sha256 "f5c096d3162e78b50dac83bbba8474036e00589952d69be29d6642c21209813f"
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
