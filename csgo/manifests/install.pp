class csgo::install (
	$srcds_path 	= $::csgo::srcds_path,
	$map 		= $::csgo::map,
	$game_type	= $::csgo::game_type,
	$game_mode	= $::csgo::game_mode,
	$mapgroup	= $::csgo::mapgroup,
        $game_directory = "/home/eevent/csgo"
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
    archive { 'csay':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'http://www.esport-tools.net/download/CSay-CSGO.zip',
        src_target => '/tmp',
	extension => 'zip'
    }
    
    exec{'mv csgo/addons/addons/* csgo/addons/':
	path => '/usr/bin:/usr/sbin:/bin',
	cwd => $game_directory,
	user => 'eevent',
	require => Archive['csay']
}

    file {"${game_directory}/csgo/cfg/autoexec.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/autoexec.cfg'
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

    $bla = [0,1,2,3,4,5,6,7,8,9,10,11]
    each($bla) |$instance| {
        $gameport = 27015 + (100*$instance)
        $tvport = 27020 + (100*$instance)
        file {"${game_directory}/start${instance}.sh":
            content => template('csgo/start.sh.erb'),
            owner => eevent,
            group => eevent,
            mode => '774',
        }
    }
}
