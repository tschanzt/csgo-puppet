class csgo::install (
	$srcds_path 	= $::csgo::srcds_path,
	$map 		= $::csgo::map,
	$game_type	= $::csgo::game_type,
	$game_mode	= $::csgo::game_mode,
	$mapgroup	= $::csgo::mapgroup,
    $game_directory = "/home/eevent/csgo/serverfiles",
    $base_dir = "/home/eevent/csgo"

	) {
    archive { 'cfg':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/cfg",
        ensure => present,
        url => 'https://gfx.esl.eu/media/counterstrike/csgo/downloads/configs/csgo_esl_serverconfig.zip',
        src_target => '/tmp',
	extension => 'zip'
    }
    exec {'mv csgo/cfg/csgo_esl_serverconfig/* csgo/cfg/':
	path => '/usr/bin:/usr/sbin:/bin',
	cwd => $game_directory,
	user => 'eevent',
	require => Archive['cfg']
   }
    archive { 'metamod':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git966-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'sm':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://sm.alliedmods.net/smdrop/1.9/sourcemod-1.9.0-git6259-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'pugsetup':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo",
        ensure => present,
        url => 'https://github.com/splewis/csgo-pug-setup/releases/download/2.0.5/pugsetup_2.0.5.zip',
        follow_redirects => true,
        src_target => '/tmp',
        strip_components => 1,
        extension => 'zip'
    }
    exec {'rsync -a csgo/pugsetup_2.0.5/cfg/* csgo/cfg/':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['pugsetup']
   }

    exec {'rsync -a csgo/pugsetup_2.0.5/addons/* csgo/addons/':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['pugsetup']
   }

    file {"${game_directory}/csgo/cfg/server.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/server.cfg'
        }

    file {"${game_directory}/set_prio.sh":
    	replace => true,
    	source => 'puppet:///modules/csgo/set_prio.sh',
    	owner => 'eevent',
    	group => 'eevent',
    	mode => '774'
    }
    file {"${base_dir}/lgsm/config-lgsm/common.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/common.cfg',
        owner => 'eevent',
        group => 'eevent',
        mode => '774'
    }

    $codefile = $::hostname?{
    'csgo-switzerlan-5'=> file('csgo/eevent-csgo-1.txt'),
    'switzerlan-csgo-6'=> file('csgo/eevent-csgo-2.txt'),
    'eevent1'=> file('csgo/eevent-csgo-3.txt'),
    'eevent2'=> file('csgo/eevent-csgo-4.txt'),
    'eevent3'=> file('csgo/eevent-csgo-5.txt'),
    'eevent4'=> file('csgo/eevent-csgo-6.txt'),
}
    $codes = $codefile.split('\n')

    $bla = [0,1,2,3,4,5,6,7]
    each($bla) |$instance| {
        $gameport = 27015 + (100*$instance)
        $tvport = 27020 + (100*$instance)
        $clientport = 27005 + (100*$instance)
        $token = $codes[$instance]
        if $instance == 0 {
            $fname = 'csgoserver.cfg'
        }
        else {
            $number = ($instance+1)
            $fname = 'csgoserver-${number}.cfg'
        }
        file {"${base_dir}/lgsm/config-lgsm/csgoserver/${fname}":
            content => template('csgo/csgoserver.cfg.erb'),
            owner => eevent,
            group => eevent,
            mode => '774',
        }
    }
}
