package IO::Storm::Bolt;
{
  $IO::Storm::Bolt::VERSION = '0.01';
}
use Moose;

extends 'IO::Storm';

use Log::Log4perl;

my $logger = Log::Log4perl->get_logger('storm.bolt');

sub process {
    my ($self, $tuple) = @_;
}

sub run {
    my ($self) = @_;

    my ($conf, $context) = $self->initbolt;
    while(1) {
        my $tup = $self->readtuple;
        $self->process($tup);
        $self->sync;
    }
}

1;
__END__
=pod

=head1 NAME

IO::Storm::Bolt

=head1 VERSION

version 0.01

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

