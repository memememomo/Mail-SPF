#
# Mail::SPF::Mod::Redirect
# SPF record "redirect" modifier class.
#
# (C) 2005-2006 Julian Mehnle <julian@mehnle.net>
#     2005      Shevek <cpan@anarres.org>
# $Id: Redirect.pm 14 2006-11-04 15:30:34Z Julian Mehnle $
#
##############################################################################

package Mail::SPF::Mod::Redirect;

=head1 NAME

Mail::SPF::Mod::Redirect - SPF record C<redirect> modifier class

=cut

use warnings;
use strict;

use Mail::SPF::Mod;
use base 'Mail::SPF::GlobalMod';

use constant TRUE   => (0 == 0);
use constant FALSE  => not TRUE;

use constant name           => 'redirect';
use constant name_pattern   => qr/${\name}/;

=head1 DESCRIPTION

An object of class B<Mail::SPF::Mod::Redirect> represents an SPF record
modifier of type C<redirect>.

=head2 Constructors

The following constructors are provided:

=over

=item B<new(%options)>: returns I<Mail::SPF::Mod::Redirect>

Creates a new SPF record C<redirect> modifier object.

%options is a list of key/value pairs representing any of the following
options:

=over

=item B<domain_spec>

See L<Mail::SPF::Mod/new>.

=back

=item B<new_from_string($text)>: returns I<Mail::SPF::Mod::Redirect>; throws
I<Mail::SPF::ENothingToParse>, I<Mail::SPF::EInvalidMod>

Creates a new SPF record C<redirect> modifier object by parsing the given
string.

=back

=head2 Class methods

The following class methods are provided:

=over

=item B<name>: returns I<string>

Returns B<'redirect'>.

=item B<name_pattern>: returns I<Regexp>

Returns a regular expression that matches a modifier name of B<'redirect'>.

=back

=head2 Instance methods

The following instance methods are provided:

=over

=cut

sub parse_params {
    my ($self) = @_;
    $self->parse_domain_spec(TRUE);
    return;
}

=item B<params>

See L<Mail::SPF::Mod/params>.

=cut

sub params {
    my ($self) = @_;
    return $self->{domain_spec};
}

=item B<domain_spec>: returns I<Mail::SPF::MacroString>

Returns the C<domain-spec> parameter of the modifier.

=cut

# Make read-only accessor:
__PACKAGE__->make_accessor('domain_spec', TRUE);

=item B<process($server, $request, $result)>: throws I<Mail::SPF::Result>

If no mechanism matched during the evaluation of the current SPF record,
performs a recursive SPF check using the given SPF server and request objects
and substituting the modifier's target domain name for the request's authority
domain.  The result of the recursive SPF check is then thrown as the result of
the current record's evaluation.  However, if the target domain has no
acceptable SPF record, a "permerror" result is thrown.  See RFC 4408, 6.1, for
details.

=cut

sub process {
    my ($self, $server, $request, $result) = @_;
    
    # Only perform redirection if no mechanism matched (RFC 4408, 6.1/1):
    $result->isa('Mail::SPF::Result::NeutralByDefault')
        or return;
    
    # Clone request with mutated authority domain:
    my $authority_domain = $self->domain($server, $request);
    my $subrequest = $request->new(authority_domain => $authority_domain);
    # Perform sub-request:
    $result = $server->process($subrequest);
    
    # Translate result of sub-request (RFC 4408, 6.1/4):
    throw Mail::SPF::Result::PermError($request,
        "Redirect domain '$authority_domain' has no sender policy")
        if $result->isa('Mail::SPF::Result::None');
    
    # Propagate any other results as-is:
    $result->throw($request);
}

=back

See L<Mail::SPF::Mod> for other supported instance methods.

=head1 SEE ALSO

L<Mail::SPF>, L<Mail::SPF::Mod>, L<Mail::SPF::Term>, L<Mail::SPF::Record>

L<http://www.ietf.org/rfc/rfc4408.txt|"RFC 4408">

For availability, support, and license information, see the README file
included with Mail::SPF.

=head1 AUTHORS

Julian Mehnle <julian@mehnle.net>, Shevek <cpan@anarres.org>

=cut

TRUE;