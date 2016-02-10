# Device-PelcoD_Parse
A Perl module to print out recieved PelcoD commands to aid in troubleshooting

# NAME
       Device::PelcoD_Parse - A module to print out recieved PelcoD commands to aid in troubleshooting

# SYNOPSIS
         use Device::PelcoD_Parse;

         my $pelco = new Device::PelcoD_Parse ( );

         # Network mode
         my $args={};
         $args->{ip} = '192.168.254.30';
         $args->{port} = 4001;
         $pelco->open_socket( $args );

         while(1)
         {
           my $rtn = $pelco->get_cmd_socket();

           $pelco->print_bin($rtn);
           # Prints the Pelco ID and 5 command and data words ... 
           # 1       00000000        00000010        00010001        00000000        00010100
           # 1       00000000        00100010        00101101        00000000        01010000
           # 1       00000000        00000000        00000000        00000000        00000001
           # 1       00000000        00010100        00111111        00000100        01011000
            
           #$pelco->print_hex($rtn);
           # Prints the Pelco ID and 5 command and data words ... 
           # 1       0       4       8       0       D
           # 1       0       0       0       0       1
           # 1       0       0       0       0       1
           # 1       0       2       9       0       C
           # 1       0       0       0       0       1
         }

         # ------------------------------------------------------------------

         # Or Serial mode
         $pelco->open_serial( {'port'=>'/dev/ttyr0e'} );

         while(1)
         {
           my $rtn = $pelco->get_cmd_socket();

           $pelco->print_bin($rtn);
         }
         
         
# DESCRIPTION
       Supports both a serial or network connection to a PelcoD Controller. The network 
       connection works with say a serial/network device like the Moxa set in TCP server mode.

# INSTALL

      Download zip file, unzip and then usual Perl module install  
      
      * perl Makefile.PL 
      * make 
      * make install  
