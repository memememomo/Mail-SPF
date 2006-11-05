#
# Module::Build build script for Mail::SPF
#
# (C) 2005-2006 Julian Mehnle <julian@mehnle.net>
# $Id$
#
##############################################################################

use Module::Build 0.26;

my $class = Module::Build->subclass( code => <<'EOF' );

    sub process_extra_files {
        my ($self, $dir) = @_;
        $dir ||= $element;
        File::Find::find(
            {
                wanted      => sub {
                    $File::Find::prune = 1 if -d and /\.svn$/;  # Exclude .svn/ dirs.
                    return if not -f;                           # Handle files only.
                    
                    my $destination = $self->copy_if_modified(
                        from    => $File::Find::name,
                        to      => File::Spec->catfile($self->blib, $File::Find::name)
                    );
                    return if not defined($destination);        # Already up to date?
                    
                    chmod((stat($File::Find::name))[2], $destination)
                        or warn("Cannot set permissions on $destination: $!");
                },
                no_chdir    => 1
            },
            $dir
        );
    }
    
#    sub process_sbin_files    { shift->process_extra_files('sbin')    }

EOF

my $build = $class->new(
    module_name     => 'Mail::SPF',
    dist_author     => [
        'Julian Mehnle <julian@mehnle.net>',
        'Shevek <cpan@anarres.org>'
    ],
    license         => 'bsd',
    requires        => {
        # Core requirements:
        perl            => 5.006,
        version         => 0,
        Getopt::Long    => 0, # 2.30
#        IO::Handle      => 0,
#        IO::File        => 0,
#        IO::Dir         => 0,
#        File::Basename  => 0,
#        File::Spec      => 0,
#        File::Path      => 0,
#        File::Find      => 0,
#        File::Copy      => 0,
        Error           => 0,
        NetAddr::IP     => 4.0,
        Net::DNS        => 0.58,
        Net::DNS::Resolver::Programmable
                        => 0,
        URI             => 1.13
    },
    recommends      => {
    },
    build_requires  => {
        # Build requirements:
        Module::Build   => 0.26,
        Test::More      => 0  # 0.40
    },
    install_path    => {
#        'sbin'          => '/usr/sbin'
    },
    create_makefile_pl
                    => 'passthrough',
    sign            => 1
);

#$build->add_build_element($_)
#    foreach qw(sbin);

$build->create_build_script();