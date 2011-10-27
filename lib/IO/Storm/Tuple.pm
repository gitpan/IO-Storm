package IO::Storm::Tuple;
{
  $IO::Storm::Tuple::VERSION = '0.01';
}
use Moose;

has 'id' => (
    is => 'rw'
);

has 'component' => (
    is => 'rw'
);

has 'stream' => (
    is => 'rw'
);

has 'task' => (
    is => 'rw'
);

has 'values' => (
    is => 'rw'
);

1;
__END__
=pod

=head1 NAME

IO::Storm::Tuple

=head1 VERSION

version 0.01

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

