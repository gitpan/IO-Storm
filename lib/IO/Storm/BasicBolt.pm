package IO::Storm::BasicBolt;
{
  $IO::Storm::BasicBolt::VERSION = '0.01';
}
use Moose;

extends 'IO::Storm';

use Log::Log4perl;

my $logger = Log::Log4perl->get_logger('storm.basicbolt');

sub process {
    my ($self, $tuple) = @_;
}
    
sub run {
    my ($self) = @_;
    # XXX

    my ($conf, $context) = $self->init_bolt;
    while(1) {
        my $tup = $self->read_tuple;
        $self->_anchor($tup);
        $self->process($tup);
        $self->ack($tup);
        $self->sync;
    }
}

1;
__END__
=pod

=head1 NAME

IO::Storm::BasicBolt

=head1 VERSION

version 0.01

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

