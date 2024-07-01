-- controlador do jogo

function controller.start()
    local this = engine.current()
    local font_path = engine.dir.get_assets_path() .. '/fonts/points.ttf'

    this._font_id = engine.font.create(font_path, 0, 128)

    -- carrega audio de fundo
    local audio_path = engine.dir.get_assets_path() .. '/sounds/background2.wav'
    local audio_path2 = engine.dir.get_assets_path() .. '/sounds/background3.wav'
    this._sound_id = engine.audio.create_2d(audio_path)
    this._sound_id_2 = engine.audio.create_2d(audio_path2)
    engine.audio.set_loop(this._sound_id, true)
    engine.audio.resume(this._sound_id)

    local cam = engine.cam2d.get(engine.cam2d.get_current())

    -- limitações da camera
    this._max_x = cam.right;
    this._max_y = cam.top;

    -- time control variable
    this._time = engine.time.get_timestamp()

    -- damage spawn
    this._next_spawn_damage_points = 2000
    this._spawn_boss = false

    this._initial_points_increase_difficulty = this.points_increase_difficulty

    -- difficuldade selecionada no menu
    this.difficulty = engine.data(engine.go.find_all('menu')[1], 'menu').difficulty
    controller.calc_difficulty()

    this._increase_font = false
    this._increase_font_time = engine.time.get_timestamp()
end

function controller.calc_difficulty()
    local this = engine.current()

    if this.difficulty >= 1 then -- wingman
        this.enemy_spawn_interval = this.enemy_spawn_interval - 0.3
        this.decrease_enemy_spawn_interval = this.decrease_enemy_spawn_interval + 0.01

        this.enemy_vel_x = this.enemy_vel_x
        this.enemy_vel_y = this.enemy_vel_y
        this.increase_enemy_vel_x = this.increase_enemy_vel_x + 0.02
        this.increase_enemy_vel_y = this.increase_enemy_vel_y + 0.01

        this.enemy_fire_rate = this.enemy_fire_rate + 0.1
        this.increase_enemy_fire_rate = this.increase_enemy_fire_rate + 0.01

        this.enemy_interval_of_fire = this.enemy_interval_of_fire - 0
        this.increase_enemy_interval_of_fire = this.increase_enemy_interval_of_fire - 0

        this.enemy_life = this.enemy_life + 2
        this.increase_enemy_life = this.increase_enemy_life + 0

        this.enemy_fire_vel = this.enemy_fire_vel + 0
        this.increase_enemy_fire_vel = this.increase_enemy_fire_vel + 0

        this.points_increase_difficulty = this.points_increase_difficulty - 50

        this.boss_life = this.boss_life + 50
        this.boss_interval_of_fire = this.boss_interval_of_fire + 0
        this.boss_fire_rate = this.boss_fire_rate + 0
        this.boss_interval_of_fire_special = this.boss_interval_of_fire_special + 0
        this.boss_fire_rate_special = this.boss_fire_rate_special + 0
        this.boss_interval_of_fire_rage = this.boss_interval_of_fire_rage + 0
        this.boss_fire_rate_rage = this.boss_fire_rate_rage + 0
        this.boss_fire_number = this.boss_fire_number + 3

        this.immune_time = this.immune_time - 0.7
    end

    if this.difficulty >= 2 then -- veteran
        this.enemy_spawn_interval = this.enemy_spawn_interval - 0.1
        this.increase_enemy_vel_x = this.increase_enemy_vel_x + 0.025
        this.increase_enemy_fire_rate = this.increase_enemy_fire_rate + 0.01
        this.enemy_interval_of_fire = this.enemy_interval_of_fire + 0.1

        this.enemy_life = this.enemy_life + 1
        this.points_increase_difficulty = this.points_increase_difficulty - 50
        this.boss_life = this.boss_life + 50
        this.boss_fire_number = this.boss_fire_number + 2
        this.immune_time = this.immune_time - 0.7
    end

    if this.difficulty >= 3 then -- ace
        this.enemy_spawn_interval = this.enemy_spawn_interval - 0.1
        this.increase_enemy_vel_x = this.increase_enemy_vel_x + 0.025
        this.increase_enemy_fire_rate = this.increase_enemy_fire_rate + 0.01
        this.enemy_interval_of_fire = this.enemy_interval_of_fire + 0.1

        this.enemy_life = this.enemy_life + 1
        this.points_increase_difficulty = this.points_increase_difficulty - 50
        this.boss_life = this.boss_life + 50
        this.boss_fire_number = this.boss_fire_number + 2
        this.immune_time = this.immune_time - 1.6
    end

    if this.difficulty >= 4 then -- god
        this.enemy_vel_x = this.enemy_vel_x + 0.2
        this.enemy_spawn_interval = this.enemy_spawn_interval - 0.1
        this.enemy_interval_of_fire = this.enemy_interval_of_fire + 0.3

        this.points_increase_difficulty = this.points_increase_difficulty - 150
        this.boss_life = this.boss_life + 100
        this.boss_fire_number = this.boss_fire_number + 2
        this.immune_time = 1.5
    end
end

-- quando inimigo foi morto, aumenta sua pontuação
function controller.on_enemy_killed(instance)
    instance.points = instance.points + instance.kill_points
    instance._increase_font = true
    instance._increase_font_time = engine.time.get_timestamp() + 0.3
end

function controller.update()
    controller.draw_points()

    if controller.game_over() then
        return
    end

    controller.spawn_enemies()
    controller.manage_difficulty()
    controller.spawn_boss()
end

function controller.manage_difficulty()
    local this = engine.current()

    if (this.points > this.points_increase_difficulty) then
        this.points_increase_difficulty = this.points_increase_difficulty + this._initial_points_increase_difficulty

        this.enemy_spawn_interval = math.max(this.enemy_spawn_interval - this.decrease_enemy_spawn_interval, 0.100) -- less 100ms each time, max is 100ms
        this.enemy_vel_y = this.enemy_vel_y + this.increase_enemy_vel_y
        this.enemy_vel_x = this.enemy_vel_x + this.increase_enemy_vel_x
        this.enemy_fire_rate = math.max(this.enemy_fire_rate - this.increase_enemy_fire_rate, 0.1)
        this.enemy_interval_of_fire = math.max(this.enemy_interval_of_fire - this.increase_enemy_interval_of_fire, 1)
        this.enemy_life = this.enemy_life + this.increase_enemy_life

        this.enemy_fire_vel = math.min(this.enemy_fire_vel + this.increase_enemy_fire_vel, 2)

        local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')

        -- cria vida
        if (fighter_go ~= nil and fighter_go.lifes <= 1 and this.points < 5000) then
            local new_id = engine.go.create_copy(engine.go.find_all('life_prefab')[1], engine.go.find_all('lifes')[1])
            engine.go.set_name(new_id, 'life')
        elseif (fighter_go ~= nil and fighter_go.lifes <= 3 and this.points < 10000) then
            local new_id = engine.go.create_copy(engine.go.find_all('life_prefab')[1], engine.go.find_all('lifes')[1])
            engine.go.set_name(new_id, 'life')
        end
    end

    if (this.points >= this._next_spawn_damage_points and this._next_spawn_damage_points < 10000) then
        this._next_spawn_damage_points = this._next_spawn_damage_points + 2000
        local new_id = engine.go.create_copy(engine.go.find_all('damage_prefab')[1], engine.go.find_all('damages')[1])
        engine.go.set_name(new_id, 'damage')
    end
end

function controller.spawn_boss()
    local this = engine.current()

    if (this.spawn_boss) then
        this.points = 10000
        local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')
        fighter_go.fires = 5
    end

    if ((this.points >= 10000 and not this._spawn_boss) or this.spawn_boss) then
        engine.go.set_active(engine.go.find_all('boss')[1], true)
        this._spawn_boss = true

        engine.audio.pause(this._sound_id)
        engine.audio.resume(this._sound_id_2)
        engine.audio.set_loop(this._sound_id_2, true)

        -- spawn lifes
        for i = 1, 2, 1 do
            local new_id = engine.go.create_copy(engine.go.find_all('life_prefab')[1], engine.go.find_all('lifes')[1])
            engine.go.set_name(new_id, 'life')
        end
    end
end

-- spawna inimigos
function controller.spawn_enemies()
    local this = engine.current()

    if this.points > 10000 then
        return
    end

    if (engine.time.get_timestamp() - this._time > this.enemy_spawn_interval) then
        this.points = this.points + 10
        this._time = engine.time.get_timestamp()

        local enemy_id = engine.go.create_copy(engine.go.find_all('enemy_prefab')[1], engine.go.find_all('enemies')[1])
        engine.go.set_name(enemy_id, 'enemy')
        engine.go.load_scripts(enemy_id)
    end
end

-- checka se jogo terminnou
function controller.game_over()
    local this = engine.current()
    local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')
    local boss_go = engine.go.find_all('boss')[1]

    if (fighter_go == nil and boss_go ~= nil) then
        local font_id = this._font_id

        engine.font.set_text(font_id, 'Erased')
        engine.font.set_color(font_id, { x = 1.0, y = 1.0, z = 1.0 })
        engine.font.set_scale(font_id, { x = 1, y = 1 })
        local half = engine.font.get_text_size(font_id).x / 2
        engine.font.set_position(font_id, { x = this._max_x / 2 - half, y = this._max_y / 2 })
        engine.font.draw(font_id)

        engine.font.set_text(font_id, 'Press ESC to menu')
        engine.font.set_color(font_id, { x = 1.0, y = 1.0, z = 1.0 })
        engine.font.set_scale(font_id, { x = 0.5, y = 0.5 })
        local half2 = engine.font.get_text_size(font_id).x / 2
        engine.font.set_position(font_id, { x = (this._max_x / 2) - half2, y = this._max_y / 2 - 130 })
        engine.font.draw(font_id)

        local space_input = engine.input.get_key(engine.enums.keyboard_key.escape)

        -- reinicia jogo
        if ((space_input == engine.enums.input_action.press)) then
            engine.restart()
        end

        return true
    end

    if (boss_go == nil) then
        local font_id = this._font_id

        engine.font.set_text(font_id, 'Congratulations')
        engine.font.set_color(font_id, { x = 1.0, y = 1.0, z = 1.0 })
        engine.font.set_scale(font_id, { x = 1, y = 1 })
        local half = engine.font.get_text_size(font_id).x / 2
        engine.font.set_position(font_id, { x = this._max_x / 2 - half, y = this._max_y / 2 })
        engine.font.draw(font_id)

        engine.font.set_text(font_id, 'Press ESC to menu')
        engine.font.set_color(font_id, { x = 1.0, y = 1.0, z = 1.0 })
        engine.font.set_scale(font_id, { x = 0.5, y = 0.5 })
        local half2 = engine.font.get_text_size(font_id).x / 2
        engine.font.set_position(font_id, { x = (this._max_x / 2) - half2, y = this._max_y / 2 - 130 })
        engine.font.draw(font_id)

        local space_input = engine.input.get_key(engine.enums.keyboard_key.escape)

        -- reinicia jogo
        if ((space_input == engine.enums.input_action.press)) then
            engine.restart()
        end

        return true
    end

    return false
end

-- desenha pontos
function controller.draw_points()
    local this = engine.current()
    local font_id = this._font_id

    local color = { x = 1.0, y = 1.0, z = 1.0 }
  
    if this.points >= 2000 then
        color.x = 0.7
        color.y = 0.7
        color.z = 0.7
    end

    if this.points >= 3000 then
        color.x = 0.7
        color.y = 0.7
        color.z = 0.0
    end

    if this.points >= 5000 then
        color.x = 1.0
        color.y = 1.0
        color.z = 0.0
    end

    if this.points >= 7000 then
        color.x = 1.0
        color.y = 0.4
        color.z = 0.0
    end

    if this.points >= 9000 then
        color.x = 1.0
        color.y = 0.3
        color.z = 0.0
    end

    if this.points >= 10000 then
        color.x = math.cos(engine.math.random())
        color.y = math.cos(engine.math.random())
        color.z = math.cos(engine.math.random())
    end

    local font_size = 0.5

    if this._increase_font == true then
        font_size = 0.54
        color.x = math.cos(engine.math.random())
        color.y = math.cos(engine.math.random())
        color.z = math.cos(engine.math.random())
        if this._increase_font_time < engine.time.get_timestamp() then
            this._increase_font = false
        end
    end

    engine.font.set_color(font_id, color)
    engine.font.set_text(font_id, 'Heat ' .. engine.to_string(math.min(this.points / 100, 100)) .. '%')
    engine.font.set_position(font_id, { x = 20, y = this._max_y - 60 })
    engine.font.set_scale(font_id, { x = font_size, y = font_size })
    engine.font.draw(font_id)
end

function controller.destroy()
    local this = engine.current()
    engine.font.destroy(this._font_id)
    engine.audio.destroy(this._sound_id)
end
