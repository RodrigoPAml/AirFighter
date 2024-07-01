-- controla tiro do boss

function boss_fire.start()
    local this = engine.current()

    local audio_path = engine.dir.get_assets_path() .. '/sounds/laser3.mp3'
    this._sound = engine.audio.create_2d(audio_path)
    this._sound_started = false
    this._texture = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_laser_boss
end

-- inicializa externalmente
function boss_fire.init(instance, x, y, vel_x, vel_y)
    instance.x = x
    instance.y = y
    instance.vel_x = vel_x
    instance.vel_y = vel_y
end

function boss_fire.update()
    local this = engine.current()

    -- som do tiro
    if (this._sound_started == false) then
        this._sound_started = true
        engine.audio.set_volume(this._sound, 0.3)
        engine.audio.resume(this._sound)
    end

    -- destroi tiro se sair da tela
    if (this.y < -100) then
        engine.go.destroy(engine.go.current())
        return
    end

    boss_fire.move()
    boss_fire.deal_damage()

    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this.size_x, y = this.size_y },
        rotation = -90,
        texture_id = this._texture,
    })
end

function boss_fire.move()
    local this = engine.current()

    -- move tiro
    this.y = this.y - (engine.get_frametime() * this.vel_y)
    this.x = this.x - (engine.get_frametime() * this.vel_x)

    -- tiro perde velocidad
    this.vel_x = this.vel_x - (0.0005 * this.vel_x * engine.get_frametime())
    this.vel_y = this.vel_y - (0.0005 * this.vel_y * engine.get_frametime())

    -- tiro tem velocidades minimas
    if this.vel_x > -0.1 and this.vel_x < 0.1 then
        if this.vel_x >= 0 then
            this.vel_x = 0.1
        else
            this.vel_x = -0.1
        end
    end

    if this.vel_y > -0.1 and this.vel_y < 0.1 then
        if this.vel_y >= 0 then
            this.vel_y = 0.1
        else
            this.vel_y = -0.1
        end
    end
end

-- calcula dano ao player
function boss_fire.deal_damage()
    local this = engine.current()
    local fighter_go = engine.data(engine.go.find_all('fighter')[1], 'fighter')

    if (fighter_go == nil) then
        return
    end

    local max_x = fighter_go.x + fighter_go.size_x / 2
    local min_x = fighter_go.x - fighter_go.size_x / 2

    if (this.x > min_x and this.x < max_x) then
        local max_y = fighter_go.y + fighter_go.size_y / 2
        local min_y = fighter_go.y - fighter_go.size_y / 2

        if (this.y > min_y and this.y < max_y) then
            if fighter.on_hit(fighter_go) then
                engine.go.destroy(engine.go.current())
            end
        end
    end
end

function boss_fire.destroy()
    local this = engine.current()
    engine.audio.destroy(this._sound)
end
