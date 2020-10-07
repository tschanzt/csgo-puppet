class csgo::install (
	$srcds_path 	= $::csgo::srcds_path,
	$map 		= $::csgo::map,
	$game_type	= $::csgo::game_type,
	$game_mode	= $::csgo::game_mode,
	$mapgroup	= $::csgo::mapgroup,
    $game_directory = "/home/eevent/csgo/serverfiles",
    $base_dir = "/home/eevent/csgo"

	) {
    file {"${game_directory}/csgo/cfg/esl5on5.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/esl5on5.cfg',
        owner => 'eevent',
        group => 'eevent',
    }
    file {"${game_directory}/csgo/cfg/eslgotv.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/eslgotv.cfg',
        owner => 'eevent',
        group => 'eevent',
    }
    archive { 'metamod':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://mms.alliedmods.net/mmsdrop/1.10/mmsource-1.10.7-git971-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'sm':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo/",
        ensure => present,
        url => 'https://sm.alliedmods.net/smdrop/1.10/sourcemod-1.10.0-git6460-linux.tar.gz',
        src_target => '/tmp',
    }
    archive { 'get5':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo",
        ensure => present,
        url => 'https://ci.splewis.net/job/get5/lastSuccessfulBuild/artifact/builds/get5/get5-502.zip',
        follow_redirects => true,
        src_target => '/tmp',
        extension => 'zip'
    }

    file {"${game_directory}/csgo/cfg/server.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/server.cfg',
        owner => 'eevent',
        group => 'eevent'
        }

    file {"${game_directory}/csgo/cfg/autoexec.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/autoexec.cfg',
        owner => 'eevent',
        group => 'eevent'
    }

    file {"${game_directory}/set_prio.sh":
    	replace => true,
    	source => 'puppet:///modules/csgo/set_prio.sh',
    	owner => 'eevent',
    	group => 'eevent',
    	mode => '774'
    }
    file {"${base_dir}/lgsm/config-lgsm/csgoserver/common.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/common.cfg',
        owner => 'eevent',
        group => 'eevent',
        mode => '774'
    }

    exec {'chmod -R 777 csgo/cfg/get5':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['get5']
    }
    exec {'chmod -R 777 csgo/addons/sourcemod/*':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['get5']
    }

    file {"${game_directory}/csgo/cfg/get5/live.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/live.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/cfg/sourcemod/get5.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/get5.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/bo1.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/bo1.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    file {"${game_directory}/csgo/bo3.cfg":
        replace => true,
        source => 'puppet:///modules/csgo/bo3.cfg',
        owner => 'eevent',
        group => 'eevent',
        require => Archive['get5'],
    }

    archive { 'steamworks':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo",
        ensure => present,
        url => 'https://github.com/KyleSanderson/SteamWorks/releases/download/1.2.3c/package-lin.tgz',
        follow_redirects => true,
        src_target => '/tmp',
    }

    archive { 'json':
        user => 'eevent',
        checksum => false,
        target => "${game_directory}/csgo",
        ensure => present,
        url => 'https://github.com/clugg/sm-json/archive/v2.0.0.tar.gz',
        strip_components => 1,
        follow_redirects => true,
        src_target => '/tmp',
    }

    exec {'mv csgo/addons/sourcemod/plugins/disabled/get5_apistats.smx csgo/addons/sourcemod/plugins/':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['get5']
    }
    exec {'mkdir csgo/round_backups':
        path => '/usr/bin:/usr/sbin:/bin',
        cwd => $game_directory,
        user => 'eevent',
        require => Archive['get5']
    }

    $codefile = $::hostname?{
    'server2'=> file('csgo/eevent-csgo-1.txt'),
    'server3'=> file('csgo/eevent-csgo-2.txt'),
    'server4'=> file('csgo/eevent-csgo-3.txt'),
    'server5'=> file('csgo/eevent-csgo-4.txt'),
    'eevent5'=> file('csgo/eevent-csgo-5.txt'),
    'eevent6'=> file('csgo/eevent-csgo-6.txt'),
}
    $codes = $codefile.split('\n')

    $bla = [0,1,2,3,4,5,6,7]
    each($bla) |$instance| {
        $gameport = 27015 + (100*$instance)
        $tvport = 27020 + (100*$instance)
        $clport = 27005 + (100*$instance)
        $token = $codes[$instance]
        $host = $::hostname
        if $instance == 0 {
            $fname = 'csgoserver.cfg'
        }
        else {
            $number = ($instance+1)
            $fname = "csgoserver-${number}.cfg"
        }
        file {"${base_dir}/lgsm/config-lgsm/csgoserver/${fname}":
            content => template('csgo/csgoserver.cfg.erb'),
            owner => eevent,
            group => eevent,
            mode => '774',
        }

        file {"${game_directory}/csgo/cfg/${fname}":
            content => template('csgo/csgoserver_csgo.cfg.erb'),
            owner => eevent,
            group => eevent,
            replace => true,
        }
    }
}
