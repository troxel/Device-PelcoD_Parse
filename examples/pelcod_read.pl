#!/usr/bin/perl 
 
use Data::Dumper;

use lib '../lib'; 
use Device::PelcoD_Parse; 

my $pelco = new Device::PelcoD_Parse ( );
#$pelco->open_serial( {'port'=>'/dev/ttyr0e'} );

my $args={};
$args->{ip} = '192.168.254.30';
$args->{port} = 4001;
$pelco->open_socket( $args );

while(1)
{
  #my $rtn = $pelco->get_cmd();
    
  my $rtn = $pelco->get_cmd_socket();

  #$pelco->print_hex($rtn);
  $pelco->print_bin($rtn);
}

