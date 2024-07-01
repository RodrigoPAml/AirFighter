-- script de um tiro dado pelo player, e calcula colisão com inimigos

function fire.start()
    local this = engine.current()

    local audio_path = engine.dir.get_assets_path() .. '/sounds/laser2.wav'
    this._sound = engine.audio.create_2d(audio_path)
    this._sound_started = false
    this._texture = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_fire

    local cam2d = engine.cam2d.get(engine.cam2d.get_current())

    this._max_x = cam2d.right;
    this._max_y = cam2d.top;
end

-- inicializa prefab externamente
function fire.init(instance, x, y, with_sound)
    instance.x = x
    instance.y = y
    instance._with_sound = with_sound
end

function fire.update()
    local this = engine.current()

    if (this._sound_started == false and this._with_sound) then
        this._sound_started = true
        engine.audio.set_volume(this._sound, 0.3)
        engine.audio.resume(this._sound)
    end

    -- se bullet saiu da tela se destroi
    if (this.y > this._max_y + 100) then
        engine.go.destroy(engine.go.current())
    end

    -- move tiro
    this.y = this.y + (engine.get_frametime() * this.vel)

    engine.draw2d.texture({
        position = { x = this.x, y = this.y },
        size = { x = this.size_x, y = this.size_y },
        rotation = 90,
        texture_id = this._texture,
    })

    fire.destroy_enemies()
end

function fire.destroy_enemies()
    -- nenhum script de inimigo existe ainda
    if (enemy == nil) then
        return
    end

    local this = engine.current()

    -- find all enemies go id
    local childrens = engine.go.get(engine.go.find_all('enemies')[1]).childrens

    -- iterate inimigos e faz teste de colisão
    for i = 1, #childrens do
        local enemy_go_id = childrens[i]
        local script_data = engine.script.get(enemy_go_id, 'enemy')

        -- script não inicializado ainda
        if (script_data.state ~= engine.enums.script_state_enum.updating) then
            goto continue
        end

        local enemy_go = engine.data(enemy_go_id, 'enemy')

        -- calcula colisão com inimigo no eixo x
        local max_x = enemy_go.x + enemy_go.size_x / 2
        local min_x = enemy_go.x - enemy_go.size_x / 2

        if (this.x > min_x and this.x < max_x) then
            -- calcula colisão com inimigo no eixo y
            local max_y = enemy_go.y + enemy_go.size_y / 2
            local min_y = enemy_go.y - enemy_go.size_y / 2

            -- se colidir desconta vidas do inimigo e se destroi
            if (this.y > min_y and this.y < max_y) then
                enemy.on_hit(enemy_go)
                engine.go.destroy(engine.go.current())
                return
            end
        end
        ::continue::
    end

    -- dano ao boss
    local boss_id = engine.go.find_all('boss')[1]

    if boss_id == nil then
        return
    end

    local boss_data = engine.data(boss_id, 'boss')
    local script_data_boss = engine.script.get(boss_id, 'boss')

    -- script não inicializado ainda
    if (script_data_boss ~= nil and script_data_boss.state ~= engine.enums.script_state_enum.updating) then
        return
    end

    if (boss_data ~= nil and boss.can_hit(boss_data) and engine.go.get(boss_id).active) then
        local max_x = boss_data.x + boss_data.size_x / 2
        local min_x = boss_data.x - boss_data.size_x / 2

        if (this.x > min_x and this.x < max_x) then
            local max_y = boss_data.y + boss_data.size_y / 2
            local min_y = boss_data.y - boss_data.size_y / 2

            if (this.y > min_y and this.y < max_y) then
                boss.on_hit(boss_data)
                engine.go.destroy(engine.go.current())
                return
            end
        end
    end
end

function fire.destroy()
    local this = engine.current()
    engine.audio.destroy(this._sound)
end
