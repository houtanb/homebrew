require 'formula'

class Dynare < Formula
  homepage 'http://www.dynare.org'
  url 'https://www.dynare.org/release/source/dynare-4.4.1.tar.xz'
  sha1 'ded88d6cacc027179e7885af78a05b2dd733ba13'

  head 'https://github.com/DynareTeam/dynare.git', :branch => 'master'

  option 'with-doc', 'Build Dynare documentation'

  depends_on :autoconf if build.head?
  depends_on :automake if build.head?
  depends_on 'bison' if build.head?

  depends_on 'xz' => :build if !build.head?
  depends_on 'octave'
  depends_on :fortran
  depends_on 'fftw'
  depends_on 'gsl'
  depends_on 'libmatio'
  depends_on 'graphicsmagick'
  depends_on 'boost' => :build
  depends_on 'slicot' => 'with-default-integer-8'
  depends_on :tex => :build if build.include? "with-doc"
  depends_on 'doxygen' => :build if build.include? "with-doc"
  depends_on 'texi2html' => :build if build.include? "with-doc"
  depends_on 'latex2html' => :build if build.include? "with-doc"

  if MacOS.version == :lion
    # FlexLexer.h that came with Lion is buggy, so patch it
    system "cp", "/usr/include/FlexLexer.h", "preprocessor"
    def patches
      "https://gist.github.com/houtanb/8269398/raw/d8cbc84389932622ed25dec31a62984cca1c58d2/FlexLexer.h.patch"
    end
  end

  def install
    system "autoreconf -si" if build.head?
    system "./configure", "--disable-debug",
                          "--disable-dependency-tracking",
                          "--disable-silent-rules",
                          "--prefix=#{prefix}",
                          "--disable-matlab"

    # "YACC=#{Formula.factory('bison').opt_prefix}/bin/bison",

    system "make"

    # Install Preprocessor
    (lib/"dynare/matlab").install "preprocessor/dynare_m"

    # Install Mex files
    (lib/"dynare/mex/octave").install "mex/build/octave/kronecker/A_times_B_kronecker_C.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/block_kalman_filter/block_kalman_filter.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/bytecode/bytecode.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/dynare_simul_/dynare_simul_.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/gensylv/gensylv.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/k_order_perturbation/k_order_perturbation.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/kalman_steady_state/kalman_steady_state.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/local_state_space_iterations/local_state_space_iteration_2.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/mjdgges/mjdgges.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/ms_sbvar/ms_sbvar_command_line.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/ms_sbvar/ms_sbvar_create_init_file.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/ordschur/ordschur.oct"
    (lib/"dynare/mex/octave").install "mex/build/octave/sobol/qmc_sequence.mex"
    (lib/"dynare/mex/octave").install "mex/build/octave/qzcomplex/qzcomplex.oct"
    (lib/"dynare/mex/octave").install "mex/build/octave/kronecker/sparse_hessian_times_B_kronecker_C.mex"

    if build.head?
      (lib/"dynare/mex/octave").install "mex/build/octave/estimation/logMHMCMCposterior.mex"
      (lib/"dynare/mex/octave").install "mex/build/octave/estimation/logposterior.mex"
    end

    # Install Matlab/Octave files
    (share/"dynare/contrib/ms-sbvar/").install Dir['contrib/ms-sbvar/TZcode']
    (share/"dynare/matlab").install Dir['matlab/*']

    # Install dynare++ executable
    bin.install("dynare++/src/dynare++")

    # Install documentation
    if build.include? "with-doc"
      doc.install "doc/dynare.pdf"
      doc.install "doc/dynare.pdf"
      doc.install "doc/bvar-a-la-sims.pdf"
      doc.install "doc/dr.pdf"
      doc.install "doc/dynare.pdf"
      doc.install "doc/guide.pdf"
      doc.install "doc/macroprocessor/macroprocessor.pdf"
      doc.install "doc/parallel/parallel.pdf"
      doc.install "doc/preprocessor/preprocessor.pdf"
      doc.install "doc/userguide/UserGuide.pdf"
      doc.install "doc/gsa/gsa.pdf"
    end
  end

  def caveats
    s = <<-EOS.undent
    Note that Homebrew did NOT install Dynare mex files for Matlab.

    If you want to install them, please download the Dynare Mac
    package, available here:

           https://www.dynare.org/download/dynare-stable
    EOS
  end
end
