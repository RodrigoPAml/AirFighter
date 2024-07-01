-- animação de explosão

function explosion.start()
    local this = engine.current()
 
    this._texture_1 = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_explosion_1
    this._texture_2 = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_explosion_2
    this._texture_3 = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_explosion_3
    this._texture_4 = engine.data(engine.go.find_all('asset_provider')[1], 'asset_provider').texture_explosion_4

    local explosion_path = engine.dir.get_assets_path() .. '/sounds/explosion.wav'
    this._sound_id = engine.audio.create_2d(explosion_path)
    this._sound_is_played = false
end

-- inicializa prefab externamente
function explosion.init(instance, x, y)
    instance.x = x
    instance.y = y
    instance._time = engine.time.get_timestamp()
end

-- desenha frames da explosão
function explosion.update()
    local this = engine.current()

    if (this._time + 0.32 < engine.time.get_timestamp()) then
        if (engine.audio.is_finished(this._sound_id)) then
            engine.go.destroy(engine.go.current())
        end

        return
    elseif (this._time + 0.24 < engine.time.get_timestamp()) then
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_4,
        })
    elseif (this._time + 0.16 < engine.time.get_timestamp()) then
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_3,
        })
    elseif (this._time + 0.08 < engine.time.get_timestamp()) then
        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_2,
        })
    elseif (this._time < engine.time.get_timestamp()) then
        if (this._sound_is_played == false) then
            engine.audio.resume(this._sound_id)
            this._sound_is_played = true
        end

        engine.draw2d.texture({
            position = { x = this.x, y = this.y },
            size = { x = this.size_x, y = this.size_y },
            texture_id = this._texture_1,
        })
    end
end

function explosion.destroy()
    local this = engine.current()
    engine.audio.destroy(this._sound_id)
end
