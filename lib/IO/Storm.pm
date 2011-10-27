package IO::Storm;
{
  $IO::Storm::VERSION = '0.01';
}
use Moose;

use IO::Handle qw(autoflush);
use IO::File;
use JSON::XS qw(decode_json encode_json);
use Log::Log4perl;
use IO::Storm::Tuple;

# ABSTRACT: Perl support for Twitter's Storm

my $logger = Log::Log4perl->get_logger('storm');


has '_anchor' => (
    is => 'rw',
    isa => 'IO::Storm::Tuple',
    predicate => '_has_anchor'
);

has '_stdin' => (
    is => 'rw',
    default => sub {
        my $io = IO::Handle->new;
        $io->fdopen(fileno(STDIN), 'r');
    }
);

sub read_string_message {
    my ($self) = @_;

    my @messages = ();
    while(1) {
        $logger->debug('reading');
        my $line = $self->_stdin->getline;
        chomp($line);
        $logger->debug("got $line");
        if($line eq 'end') {
            last;
        }
        push(@messages, $line);
    }
    return join("\n", @messages);
}


sub read_message {
    my ($self) = @_;

    return decode_json($self->read_string_message);
}


sub send_message_to_parent {
    my ($self, $href) = @_;

    $self->send_to_parent(encode_json($href));
}


sub send_to_parent {
    my ($self, $s) = @_;

    $logger->debug("sending $s");
    print "$s\n";
    $logger->debug('sending end');
    print "end\n";
}


sub sync {
    my ($self) = @_;
    $logger->debug('sending sync');
    print "sync\n";
}


sub send_pid {
    my ($self, $hbdir) = @_;

    my $pid = $$;
    print "$pid\n";
    $logger->debug("sent $pid");
    
    # XXX error handling
    my $fh = IO::File->new;
    $fh->open('> '.$hbdir.'/'.$pid);
    $fh->close;
    
    $logger->debug("wrote pid to $hbdir/$pid");
}


sub emit_tuple {
    my ($self, $tuple, $stream, $anchors, $direct_task) = @_;
    
    my %message = ( command => 'emit' );
    if(defined($stream)) {
        $message{stream} = $stream;
    }
    if($self->_has_anchor) {
        # The python implementation maps this, but just works with a single
        # anchor.  Perhaps it was there for some other feature?
        $message{anchors} = [ $self->_anchor->id ];
    }
    if(defined($direct_task)) {
        $message{task} = $direct_task;
    }
    $message{tuple} = $tuple;
    $self->send_message_to_parent(\%message);
}


sub emit {
    my ($self, $tuple, $stream, $anchors) = @_;
    
    $anchors = [];
    $self->emit_tuple($tuple, $stream, $anchors);
    return $self->read_message;
}


sub emit_direct {
    my ($self, $task, $tuple, $stream, $anchors) = @_;

    emit_tuple($tuple, $stream, $anchors, $task);
}


sub ack {
    my ($self, $tuple) = @_;
    
    $self->send_message_to_parent({ command => 'ack', id => $tuple->id })
}


sub fail {
    my ($self, $tuple) = @_;
    
    $self->send_message_to_parent({ command => 'fail', id => $tuple->id })
}


sub log {
    my ($self, $message) = @_;
    
    $self->send_message_to_parent({ command => 'log', msg => $message })
}


sub read_env {
    my ($self) = @_;
    $logger->debug('read_env');
    my $conf = $self->read_message;
    my $context = $self->read_message;
    
    return [ $conf, $context ];
}


sub read_tuple {
    my ($self) = @_;

    my $tupmap = $self->read_message;

    return IO::Storm::Tuple->new(
        id      => $tupmap->{id},
        component => $tupmap->{comp},
        stream  => $tupmap->{stream},
        task    => $tupmap->{task},
        values  => $tupmap->{tuple}
    );
}


sub init_bolt {
    my ($self) = @_;
    
    autoflush STDOUT 1;
    
    $logger->debug('init_bolt');
    my $hbdir = $self->read_string_message;
    $self->send_pid($hbdir);
    return $self->read_env;
}

1;

__END__
=pod

=head1 NAME

IO::Storm - Perl support for Twitter's Storm

=head1 VERSION

version 0.01

=head1 SYNOPSIS

    package SplitSentenceBolt;
    use Moose;

    extends 'Storm::BasicBolt';

    sub process {
        my ($self, $tuple) = @_;

        my @words = split(' ', $tuple->values->[0]);
        foreach my $word (@words) {

            $self->emit([ $word ]);
        }
    }

    SplitSentenceBolt->new->run;

=head1 DESCRIPTION

IO::Storm allows you to leverage Storm's multilang support to write Bolts
(and someday, more) in Perl.

=head1 METHODS

=head2 read_string_message

Read a message from the ShellBolt.  Reads until it finds a "end" line.

=head2 read_message

Read a message from the ShellBolt and decode it from JSON.

=head2 send_message_to_parent

Sent a message to the ShellBolt, encoding it as JSON.

=head2 send_to_parent

Send a message to the ShellBolt.

=head2 sync

Send a sync.

=head2 send_pid

Send this processes PID.

=head2 emit_tuple

Send a tuple to the ShellBolt.

=head2 emit

Emit a tuple to the the ShellBolt and return the response.

=head2 emit_direct

Emit a tuple to the Shell bolt, but do not get a response.

=head2 ack

Acknowledge a tuple.

=head2 fail

Fail a tuple.

=head2 log

Send a log command to the ShellBolt

=head2 read_env

Read the configuration and context from the ShellBolt.

=head2 read_tuple

Turn the incoming Tuple structure into an L<IO::Storm::Tuple>.

=head2 init_bolt

Initialize this bolt.

=head1 AUTHOR

Cory G Watson <gphat@cpan.org>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2011 by Infinity Interactive, Inc.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

