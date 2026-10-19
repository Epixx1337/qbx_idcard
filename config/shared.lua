return {
    idCardSettings = {
        closeKey = 'BACK', -- https://docs.fivem.net/docs/game-references/input-mapper-parameter-ids/keyboard
        autoClose = {
            status = false,
            time = 3000
        }
    },

    commands = {
        designer = 'idcards',
        give = 'givecard',
        restricted = 'group.admin',
    },

    handheld = {
        card = {
            dict = 'paper_1_rcm_alt1-9',
            clip = 'player_one_dual-9',
            prop = 'prop_franklin_dl',
            bone = 57005,
            pos = vec3(0.1, 0.02, -0.03),
            rot = vec3(-90.0, 170.0, 79.0),
            duration = 3500,
        },
        badge = {
            dict = 'paper_1_rcm_alt1-9',
            clip = 'player_one_dual-9',
            prop = 'prop_fib_badge',
            bone = 28422,
            pos = vec3(0.065, 0.029, -0.035),
            rot = vec3(80.0, -1.9, 75.0),
            duration = 3500,
        },
    },

    -- Default cards, used until an admin saves a design for the item with /idcards
    licenses = {
        ['id_card'] = {
            header = 'Identity',
            background = '#ebf7fd',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl'
        },
        ['driver_license'] = {
            header = 'Driver License',
            background = '#febbbb',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl',
        },
        ['weaponlicense'] = {
            header = 'Weapon License',
            background = '#c7ffe5',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_franklin_dl',
        },
        ['lawyerpass'] = {
            header = 'Lawyer Pass',
            background = '#f9c491',
            backgroundImage = 'https://i.ibb.co/vxvGzg1/card.png',
            prop = 'prop_cs_r_business_card'
        },
        ['police_badge'] = {
            header = 'Police Department',
            kind = 'badge',
            background = '#1a1b1e',
            badge = 'examplebadge',
            prop = 'prop_fib_badge',
            jobs = { 'police' },
        },
    }
}
