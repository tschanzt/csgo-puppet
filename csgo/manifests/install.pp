class csgo::install (
	$srcds_path 	= $::csgo::srcds_path,
	$map 		= $::csgo::map,
	$game_type	= $::csgo::game_type,
	$game_mode	= $::csgo::game_mode,
	$mapgroup	= $::csgo::mapgroup,
    $instances = [0,1,2,3,4,5,6,7,8,9,10,11]
	) {
    archive { 'stcmd':
        user => 'eevent',
        checksum => false,
        target => $game_directory/csgo/cfg,
        ensure => present,
        url => 'https://gfx.esl.eu/media/counterstrike/csgo/downloads/configs/csgo_esl_serverconfig.zip',
        src_target => '/tmp'
    }

    archive { 'csay':
        user => 'eevent',
        checksum => false,
        target => $gamedirectory/csgo/addons/,
        ensure => present,
        url => 'http://www.esport-tools.net/download/CSay-CSGO.zip',
        src_target => '/tmp'
    }

    file {'${game_directory}/csgo/cfg/autoexec.cfg',
        replace => true,
        source = 'puppet:///modules/csgo/csgo/files/autoexec.cfg'
        }

    file {'${game_directory}/csgo/cfg/server.cfg',
        replace => true,
        source = 'puppet:///modules/csgo/csgo/files/server.cfg'
        }

    $instances.each |int $instance| {
        $gameport = 27015 + (100*$instance)
        $tvport = 27020 + (100*$instance)
        file {'./start${instance}.sh':
            content => template('csgo/templates/start.sh.erb'),
            owner => eevent,
            group => eevent,
            mode => 744,
        }
    }
