require 'formula'

class Pymol < Formula
  homepage 'http://pymol.org'
  url 'http://downloads.sourceforge.net/project/pymol/pymol/1.6/pymol-v1.6.0.0.tar.bz2'
  sha1 '0446fd67ef22594eb5060ab07e69993c384b2e41'
  head 'https://pymol.svn.sourceforge.net/svnroot/pymol/trunk/pymol'

  depends_on "glew"
  depends_on 'Pmw'
  depends_on 'python' => 'with-brewed-tk'
  depends_on 'homebrew/dupes/tcl-tk' => ['enable-threads','with-x11']
  depends_on :freetype
  depends_on :libpng
  depends_on :x11

  # To use external GUI tk must be built with --enable-threads
  # and python must be setup to use that version of tk with --with-brewed-tk
  depends_on 'Tkinter' => :python

  option 'default-stereo', 'Set stereo graphics as default'

  def install
    # PyMol uses ./ext as a backup to look for ./ext/include and ./ext/lib
    ln_s HOMEBREW_PREFIX, "./ext"

    temp_site_packages = lib/which_python/'site-packages'
    mkdir_p temp_site_packages
    ENV['PYTHONPATH'] = temp_site_packages

    args = [
      "--verbose",
      "install",
      "--install-scripts=#{bin}",
      "--install-lib=#{temp_site_packages}",
    ]

    # build the pymol libraries
    system "python", "-s", "setup.py", *args

    # get the executable
    bin.install("pymol")
  end

  def patches
    p = []
    # This patch adds checks that force mono as default
    p << 'https://gist.github.com/scicalculator/1b84b2ad3503395f1041/raw/2a85dc56b4bd1ea28d99ce0b94acbf7ac880deff/pymol_disable_stereo.diff' unless build.include? 'default-stereo'
    # This patch disables the vmd plugin. VMD is not something we can depend on for now. The plugin is set to always install as of revision 4019.
    p << 'https://gist.github.com/scicalculator/4966279/raw/9eb79bf5b6a36bd8f684bae46be2fcf834fea8de/pymol_disable_vmd_plugin.diff'
    p
  end

  def which_python
    "python" + `python -c 'import sys;print(sys.version[:3])'`.strip
  end

  def test
    # commandline test
    system "pymol","-c"
    # if build.include? "gui"
    #   # serious bench test
    #   system "pymol","-b","-d","quit"
    # end
  end

  def caveats
    <<-EOS.undent

    In order to get the most out of pymol, you will want the external
    gui. This requires a thread enabled tk installation and python
    linked to it. Install these with the following commands.
      brew tap homebrew/dupes
      brew install homebrew/dupes/tcl-tk --enable-threads --with-x11
      brew install python --with-brewed-tk

    On some macs, the graphics drivers do not properly support stereo
    graphics. This will cause visual glitches and shaking that stay
    visible until x11 is completely closed. This may even require
    restarting your computer. Therefore, we install pymol in a way that
    defaults to mono graphics. This is equivalent to running pymol with
    the "-M" option. You can still run in stereo mode by running
      pymol -S

    You can install pymol such that it defaults to stereo with the
    "--default-stereo" option.

    EOS
  end

end
