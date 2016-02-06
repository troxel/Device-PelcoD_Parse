package Device::PelcoD_Parse;

use 5.010001;
use strict;
use warnings;
use Data::Dumper;

our @ISA = qw();

our $VERSION = '1.0';

# Preloaded methods go here.

# ==========================================================================
# PelcoD Protocol Parsing  
# ==========================================================================

use Time::HiRes qw( usleep );

use constant SYNC => 0xff;
use constant COMMAND_GAP => 100000; # In ms

our %cmd1 = 
(
  0x02 => 'pan right',
  0x04 => 'pan left',
  0x08 => 'tilt up',
  0x10 => 'tilt down',
  0x20 => 'zoom tele',
  0x80 => 'zoom wide',
  0xA  => 'pan right tilt up'
);

our %cmd2 = 
(
  0x02 => '',
  0x04 => '',
  0x08 => '',
  0x10 => '',
  0x20 => '',
  0x80 => '',
  0xA  => ''
);

# -----------------------------------------
sub new
{
  my $class = shift;
  my $args = shift; 
     
  my $self = 
  {
    'id'=>$args->{id},
    'port_obj'=>'',  
    'sync'=>0,     
    'buffer_byte'=>[],     
    'buffer_char'=>[],     
  };
    
  bless( $self, $class );
  return $self;
}

sub open_serial 
{
  my $self = shift;
  my $args = shift; 

  unless ( $args->{port} ) { die 'Port must be defined' }   

  use Device::SerialPort;
  my $port_obj = new Device::SerialPort( $args->{port} );
  unless ( $port_obj ) { die "Cannot connect to $args->{port}" }
  
  my $baudrate = $args->{baudrate} || 2400; 
  
  $port_obj->baudrate($baudrate);
 
  $port_obj->baudrate(2400);
  $port_obj->databits(8);
  $port_obj->parity('none');
  $port_obj->stopbits(1);
  $port_obj->handshake('none');

  $port_obj->read_char_time(5);     # don't wait for each character
  $port_obj->read_const_time(100); # 1 second per unfulfilled "read" call

  $self->{port_obj} = $port_obj,  

  return $self;
}

sub open_socket
{
  my $self = shift;
  my $args = shift; 

  unless ( $args->{port} ) { die 'Port must be defined' }   
  unless ( $args->{ip} ) { die 'Port must be defined' }   

  use IO::Socket::INET;
  
  my $sock = IO::Socket::INET->new(PeerAddr => $args->{ip},
                                 PeerPort => $args->{port},
                                 Proto    => 'tcp');
                                 
  unless ( $sock ) { print "Can't open socket $!\n"; print Dumper $args; exit; }
  
  $self->{socket_obj} = $sock; 
 
  return $self;
}

# -----------------------------------------
#our $AUTOLOAD;
#sub AUTOLOAD
#{
#    my $self = shift;
#    my $class = ref($self) || croak( "$self not object" );
#    my $name = $AUTOLOAD;
#    
#    print $name; exit; 
#    
#    $name =~ s/.*://;
#    if ( exists($self->{$name}) )
#    {
#        return( $self->{$name} );
#    }
#    Fatal( "Can't access $name member of object of class $class" );
#}

# -----------------------------------------
sub close
{
    my $self = shift;
    $self->{state} = 'closed';
    $self->{port_obj}->close();
}

# -----------------------------------------
sub get_cmd
{
  my $self = shift; 

  if ( scalar @{ $self->{buffer_char} } )
  {
    return shift @{ $self->{buffer_char} }; 
  }
	
	$|=1; 
 
  my ($count, $rx_msg_byte);

  while (1) 
	{
		( $count, $rx_msg_byte ) = $self->{port_obj}->read(7);
		print "."; 
		if ( $count ) { last }
	}	
  print "\n"; 
	
  my @rx_msg = unpack "C*", $rx_msg_byte;
 
	my $inx=-1; 	
	
	#print Dumper \@rx_msg; print "\n------\n"; 
	
	foreach my $str ( @rx_msg ) 
  {
	  if ( $str == 0xFF ) { $inx++; next;  }
    unless ( $inx >= 0 ) { next; }
		
	  push @{${$self->{buffer_char}}[$inx]}, $str; 
  }

	#print Dumper $self->{buffer_char}; 
	my $lst_ref = shift @{ $self->{buffer_char} } ;	 
	
	return $lst_ref; 
}	

# -----------------------------------------
sub get_cmd_socket_buffer
{
  my $self = shift; 

  if ( scalar @{ $self->{buffer_char} } )
  {
    return shift @{ $self->{buffer_char} }; 
  }
	
  my $rx_msg_byte;
	$self->{socket_obj}->recv($rx_msg_byte,1024);
	
  my @rx_msg = unpack "C*", $rx_msg_byte;
 
	my $inx=-1; 	
	foreach my $str ( @rx_msg ) 
  {
	  if ( $str == 0xFF ) { $inx++; next;  }
    unless ( $inx >= 0 ) { next; }
		
	  push @{${$self->{buffer_char}}[$inx]}, $str; 
  }

	#print Dumper $self->{buffer_char}; 
	my $lst_ref = shift @{ $self->{buffer_char} } ;	 
	
	return $lst_ref; 
}	

# -----------------------------------------
sub get_cmd_socket
{
  my $self = shift;

  my @rx_msg_cmd;
  while(1)
  {
    my $rx_msg_byte;
    $self->{socket_obj}->recv($rx_msg_byte,1);

    if ( $rx_msg_byte eq '' ) { next; }

    my $rx_msg = unpack "C*", $rx_msg_byte;

    if ( $rx_msg == 0xFF ) { last; }
    push @rx_msg_cmd, $rx_msg;
  }

  return \@rx_msg_cmd;
}

# -----------------------------------------
sub print_bin
{
  my $self = shift; 
  my $cmd_ref = shift; 

  print "$cmd_ref->[0] "; 
  shift @{$cmd_ref};   
	
  foreach my $char ( @{$cmd_ref} )
  {
    printf "\t%08B", $char;
  }
  
  print "\n"; 
} 	

1;

__END__
# Below is stub documentation for your module. You'd better edit it!

=head1 NAME

Device::PelcoD_Parse - A module to print out recieved PelcoD commands to aid in troubleshooting

=head1 SYNOPSIS

  use Device::PelcoD_Parse;
 
  my $pelco = new Device::PelcoD_Parse ( );
  
  # Serial mode 
  $pelco->open_serial( {'port'=>'/dev/ttyr0e'} );
   
  or 
  
  # Network mode 
  my $args={};
  $args->{ip} = '192.168.254.30';
  $args->{port} = 4001;
  $pelco->open_socket( $args );

  while(1)
  {
    my $rtn = $pelco->get_cmd();
    my $rtn = $pelco->get_cmd_socket();

    $pelco->print_bin($rtn);
  }


=head1 DESCRIPTION

Supports both a serial or network connection to a PelcoD Controller. The network 
connection works with say a serial/network device like the Moxa set in TCP server mode. 


=head1 SEE ALSO

Some code borrowed from Zonemaster 

=head1 AUTHOR

E<lt>steven.troxel at gmail dot com<gt>

=head1 COPYRIGHT AND LICENSE

Copyright (C) 2016 by Steve Troxel

This library is free software; you can redistribute it and/or modify
it under the same terms as Perl itself, either Perl version 5.10.1 or,
at your option, any later version of Perl 5 you may have available.

=cut
