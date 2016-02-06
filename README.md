# Device-PelcoD_Parse
A Perl module to print out recieved PelcoD commands to aid in troubleshooting

# NAME
       Device::PelcoD_Parse - A module to print out recieved PelcoD commands to aid in troubleshooting

# SYNOPSIS
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

# DESCRIPTION
       Supports both a serial or network connection to a PelcoD Controller. The network connection works with say a serial/network
       device like the Moxa set in TCP server mode.
