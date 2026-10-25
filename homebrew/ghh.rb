# Homebrew formula for ghh
# Host this file in a separate repo: jgorodetsky/homebrew-ghh
# Then users can: brew tap jgorodetsky/ghh && brew install ghh

class Ghh < Formula
  desc "Your entire git + GitHub workflow in one searchable command"
  homepage "https://github.com/jgorodetsky/ghh"
  url "https://github.com/jgorodetsky/ghh/archive/refs/tags/v0.5.0.tar.gz"
  sha256 "45474a30e195dbdbf333d75f24d1f84d691f58e6a8841b8a72ed1f537c97e49f"
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
