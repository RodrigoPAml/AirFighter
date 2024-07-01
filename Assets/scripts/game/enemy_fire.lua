-- controla tiro inimigo

function enemy_fire.start()
    local this = engine.current()

    local audio_path = engine.dir.get_assets_path() .. '/sounds/laser.mp3'
    this._sound = engine.audio.create_2d(audio_path)
    this._sound_started = false
    
    this._texture = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_laser_enemy

    enemy_fire.start_attributes()
end

function enemy_fire.start_attributes()
    local this = engine.current()
    local controller_go = engine.data(engine.go.find_all('controller')[1], 'controller') 
    this._vel = controller_go.enemy_fire_vel
end

-- inicializa externalmente
function enemy_fire.init(instance, x, y)
    instance.x = x
    instance.y = y
end

function enemy_fire.update()
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

    enemy_fire.move()
    enemy_fire.deal_damage()
    
    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this.size_x, y = this.size_y },
        rotation = -90,
        texture_id = this._texture,
    })
end

function enemy_fire.move()
    local this = engine.current()

    -- move tiro
    this.y = this.y - (engine.get_frametime() * this._vel)
end

-- calcula dano ao player
function enemy_fire.deal_damage()
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

function enemy_fire.destroy()
    local this = engine.current()
    engine.audio.destroy(this._sound)
end
