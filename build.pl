my $CPANM_URL = 'http://cpanmin.us';

my $GIT_VERSION = '1.7.6';
my $GIT_URL     = "http://kernel.org/pub/software/scm/git/git-${GIT_VERSION}.tar.bz2";

my $ZLIB_VERSION = '1.2.5';
my $ZLIB_URL     = "http://prdownloads.sourceforge.net/libpng/zlib-${ZLIB_VERSION}.tar.bz2?download";

deftask 'base-dirs' => sub {
    shell "mkdir -p $BASEDIR/{bin,lib,man,share,src}"
};

sub append_path {
    my ( $var_name, $value ) = @_;
    if ( $ENV{$var_name} ) {
        $ENV{$var_name} = $value . ':' . $ENV{$var_name};
    }
    else {
        $ENV{$var_name} = $value;
    }
}

deftask 'setenv' => sub {
    append_path PATH            => "$BASEDIR/bin";
    append_path LD_LIBRARY_PATH => "$BASEDIR/lib";
    append_path MANPATH         => "$BASEDIR/man";
};

deftask 'env' => sub {
    depends "setenv";
    shell 'env';
};

deftask 'cpanm' => sub {
    depends "base-dirs,setenv";
    my $cpanm = "$BASEDIR/bin/cpanm";
    shell "wget -O $cpanm $CPANM_URL" unless -e $cpanm;
    chmod 0755, "$cpanm" unless -x $cpanm;
};

deftask 'local-lib' => sub {
    depends "cpanm";
    shell "cpanm -l $BASEDIR local::lib";
};

deftask 'zlib' => sub {
    depends "base-dirs,setenv";
    my $tarball = "zlib-${ZLIB_VERSION}.tar.bz2";
    shell <<"EOT";
cd $BASEDIR/src
test -e $tarball || wget -v $ZLIB_URL -O $tarball
test -d zlib-${ZLIB_VERSION} || tar xf $tarball
cd zlib-${ZLIB_VERSION}
./configure --prefix=$BASEDIR
make
make install
EOT
};

deftask 'git' => sub {
    depends "base-dirs,setenv,zlib";
    shell <<"EOT";
cd $BASEDIR/src
wget -N -v $GIT_URL
tar xf git-${GIT_VERSION}.tar.bz2
cd git-$GIT_VERSION
./configure --prefix=$BASEDIR --with-zlib=$BASEDIR
make
make install
EOT
};

1;
