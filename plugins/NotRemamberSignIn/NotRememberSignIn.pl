package MT::Plugin::NotRememberSignIn;
use strict;
use warnings;
use base qw( MT::Plugin );

my $plugin = __PACKAGE__->new(
    {   name        => 'NotRememberSignIn',
        version     => '0.01',
        author_name => 'masiuchi',
        author_link => 'https://github.com/masiuchi',
        plugin_link =>
            'https://github.com/masiuchi/mt-plugin-not-remember-sign-in',
        description =>
            '<__trans phrase="Disable the remember function when logging in.">',

        init_app => \&_init_app,

        registry => {
            l10n_lexicon => {
                ja => {
                    'Disable the remember function when logging in.' =>
                        'サインイン情報を記憶しないようにします。',
                },
            },

            applications => {
                cms => {
                    callbacks => {
                        'template_source.login_mt' => \&_tmpl_src_login_mt,
                    },
                },
            },
        },
    }
);
MT->add_plugin($plugin);

sub _init_app {
    use MT::Core;
    use MT::Session;
    use MT::Auth;
    my $handle = \&MT::Auth::_handle;

    no warnings 'redefine';
    *MT::Core::purge_user_session_records = sub {
        my ( $kind, $timeout ) = @_;
        my $iter = MT::Session->remove(
            {   kind  => $kind,
                start => [ undef, time - $timeout ],
            },
            { range => { start => 1 } }
        );
    };
    *MT::Auth::_handle = sub {
        if ( $_[0] eq 'validate_credentials' ) {
            MT::Core::purge_user_session_records( 'US',
                MT->config->UserSessionTimeout );
        }
        return $handle->(@_);
    };
}

sub _tmpl_src_login_mt {
    my ( $cb, $app, $tmpl ) = @_;
    my $html = quotemeta
        '<label for="remember"><input type="checkbox" name="remember" id="remember" value="1" accesskey="r" /> <__trans phrase="Remember me?"></label>';
    $$tmpl =~ s/$html//;
}

1;
