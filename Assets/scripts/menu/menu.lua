-- script do menu principal

function menu.start()
    local this = engine.current()

    -- carrega imagem de fundo
    local menu_img = engine.dir.get_assets_path() .. '/images/menu.jpg'
    this._texture_id = engine.texture.create({
        minifying_filter = engine.enums.minifying_filter.linear_mipmap_linear,
        magnification_filter = engine.enums.magnification_filter.linear,
        texture_wrap_t = engine.enums.texture_wrap.mirror_clamp_to_edge,
        texture_wrap_s = engine.enums.texture_wrap.mirror_clamp_to_edge,
        ansiotropic_filter = 1,
        border_color = { x = 0, y = 0, z = 0 },
        image_path = menu_img
    })

    -- carrega fonte
    local font_path = engine.dir.get_assets_path() .. '/fonts/menu.ttf'
    this._font_id = engine.font.create(font_path, 0, 128)

    -- carrega audio de fundo
    local audio_path = engine.dir.get_assets_path() .. '/sounds/background.wav'

    this._sound_id = engine.audio.create_2d(audio_path)
    engine.audio.set_loop(this._sound_id, true)
    engine.audio.resume(this._sound_id)

    -- opção selecionada no menu
    this._option = -1

    -- tela selecionada (1 - principal, 2 - dificuldade)
    this._screen = 1
    this._change_screen = false

    -- dificuldade (1 - Recruta, 2 - Asa Novata, 3 - Veterano, 4 - Ás dos Céus)
    this.difficulty = 1

    -- camera coordinates
    local cam = engine.cam2d.get(engine.cam2d.get_current())

    this._max_x = cam.right;
    this._max_y = cam.top;
end

function menu.update()
    local this = engine.current()

    menu.draw_background()
    menu.draw_title()

    if (this._screen == 1) then
        menu.draw_buttons()
        menu.draw_texts()
    else
        menu.draw_buttons_difficulty()
        menu.draw_texts_difficulty()
    end
end

-- desenha fundo
function menu.draw_background()
    local this = engine.current()

    engine.draw2d.texture({
        position = { x = this._max_x / 2, y = this._max_y / 2 },
        size = { x = this._max_x, y = this._max_y },
        texture_id = this._texture_id,
    })
end

-- desenha botões, colisões e ações
function menu.draw_buttons_difficulty()
    local this = engine.current()

    local button_size = 300;
    local mouse_pos = engine.input.get_cam_mouse_pos()

    -- coordenadas dos botões
    local button_x_min = this._max_x / 2 - button_size / 2;
    local button_x_max = this._max_x / 2 + button_size / 2;

    local button_y_min_0 = this._max_y / 2 + 60
    local button_y_max_0 = this._max_y / 2 + 90 + 60

    local button_y_min_1 = this._max_y / 2 - 210 + 65 + 60
    local button_y_max_1 = this._max_y / 2 - 120 + 65 + 60

    local button_y_min_2 = this._max_y / 2 - 210 - 75 + 60
    local button_y_max_2 = this._max_y / 2 - 120 - 75 + 60

    local button_y_min_3 = this._max_y / 2 - 210 - 215 + 60
    local button_y_max_3 = this._max_y / 2 - 120 - 215 + 60

    local button_y_min_4 = this._max_y / 2 - 210 - 355 + 60
    local button_y_max_4 = this._max_y / 2 - 120 - 355 + 60

    -- colisão do botão
    if (mouse_pos.x > button_x_min and mouse_pos.x < button_x_max) then
        if (mouse_pos.y > button_y_min_0 and mouse_pos.y < button_y_max_0) then
            this._option = 0
        elseif (mouse_pos.y > button_y_min_1 and mouse_pos.y < button_y_max_1) then
            this._option = 1
        elseif (mouse_pos.y > button_y_min_2 and mouse_pos.y < button_y_max_2) then
            this._option = 2
        elseif (mouse_pos.y > button_y_min_3 and mouse_pos.y < button_y_max_3) then
            this._option = 3
        elseif (mouse_pos.y > button_y_min_4 and mouse_pos.y < button_y_max_4) then
            this._option = 4
        else
            this._option = -1
        end
    else
        this._option = -1
    end

    -- ações dos botões
    if (this._option ~= -1 and this._change_screen == false and engine.input.get_mouse_button(engine.enums.mouse_button.left) == engine.enums.input_action.press) then
        this.difficulty = this._option;

        engine.go.set_active(engine.go.current(), false)
        engine.go.set_active(engine.go.find_all('game')[1], true)
        engine.audio.pause(this._sound_id)
    end

    if (this._change_screen and engine.input.get_mouse_button(engine.enums.mouse_button.left) == engine.enums.input_action.release) then
        this._change_screen = false
    end

    engine.command.set_primitive_line_size(5)

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 520 + 60 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 380 + 60 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 240 + 60 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 100 + 60 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 + 45 + 60 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    -- desenha botão selecionado
    if (this._option == 0) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_0 + button_y_max_0) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 1) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_1 + button_y_max_1) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 2) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_2 + button_y_max_2) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 3) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_3 + button_y_max_3) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 4) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_4 + button_y_max_4) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    end
end

-- desenha textos dos botões
function menu.draw_texts_difficulty()
    local this = engine.current()

    local font_id = this._font_id

    engine.font.set_text(font_id, 'Rookie')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 85, y = this._max_y - 530 + 60 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'Wingman')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 100, y = this._max_y - 665 + 60 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.6 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'Veteran')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 110, y = this._max_y - 815 + 60 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'Ace')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 50, y = this._max_y - 955 + 60 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'God')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 50, y = this._max_y - 1095 + 60 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 1.0, y = 0.0, z = 0.0 })
    engine.font.draw(font_id)
end

-- desenha botões, colisões e ações
function menu.draw_buttons()
    local this = engine.current()

    local button_size = 300;
    local mouse_pos = engine.input.get_cam_mouse_pos()

    -- coordenadas dos botões
    local button_x_min = this._max_x / 2 - button_size / 2;
    local button_x_max = this._max_x / 2 + button_size / 2;

    local button_y_min_0 = this._max_y / 2
    local button_y_max_0 = this._max_y / 2 + 90

    local button_y_min_1 = this._max_y / 2 - 210 + 65
    local button_y_max_1 = this._max_y / 2 - 120 + 65

    local button_y_min_2 = this._max_y / 2 - 210 - 75
    local button_y_max_2 = this._max_y / 2 - 120 - 75

    -- colisão do botão
    if (mouse_pos.x > button_x_min and mouse_pos.x < button_x_max) then
        if (mouse_pos.y > button_y_min_0 and mouse_pos.y < button_y_max_0) then
            this._option = 0
        elseif (mouse_pos.y > button_y_min_1 and mouse_pos.y < button_y_max_1) then
            this._option = 1
        elseif (mouse_pos.y > button_y_min_2 and mouse_pos.y < button_y_max_2) then
            this._option = 2
        else
            this._option = -1
        end
    else
        this._option = -1
    end

    -- ações dos botões
    if (this._option == 0 and engine.input.get_mouse_button(engine.enums.mouse_button.left) == engine.enums.input_action.press) then
        this._screen = 2
        this._change_screen = true
    end

    if (this._option == 1 and engine.input.get_mouse_button(engine.enums.mouse_button.left) == engine.enums.input_action.press) then
        engine.dir.exec('explorer https://github.com/RodrigoPAml/BoxEngine')
    end

    if (this._option == 2 and engine.input.get_mouse_button(engine.enums.mouse_button.left) == engine.enums.input_action.press) then
        engine.stop()
    end

    engine.command.set_primitive_line_size(5)

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 240 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 - 100 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    engine.draw2d.rect({
        position = { x = this._max_x / 2, y = this._max_y / 2 + 45 },
        size = { x = button_size, y = 100 },
        color = { x = 0, y = 0, z = 0, w = 0.5 },
        filled = true,
    })

    -- desenha botão selecionado
    if (this._option == 0) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_0 + button_y_max_0) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 1) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_1 + button_y_max_1) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    elseif (this._option == 2) then
        engine.draw2d.rect({
            position = { x = this._max_x / 2, y = (button_y_min_2 + button_y_max_2) / 2 },
            size = { x = button_size, y = 100 },
            color = { x = 1, y = 0, z = 0, w = 1 },
            filled = false,
        })
    end
end

-- desenha titulo
function menu.draw_title()
    local this = engine.current()

    local font_id = this._font_id

    engine.font.set_text(font_id, 'Air Fighter')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 330, y = this._max_y - 300 })
    engine.font.set_color(font_id, { x = 0.0, y = 0.0, z = 0.0 })
    engine.font.set_scale(font_id, { x = 1.5, y = 1.5 })
    engine.font.draw(font_id)
end

-- desenha textos dos botões
function menu.draw_texts()
    local this = engine.current()

    local font_id = this._font_id

    engine.font.set_text(font_id, 'Start')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 80, y = this._max_y - 530 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'About')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 80, y = this._max_y - 675 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)

    engine.font.set_text(font_id, 'Exit')
    engine.font.set_position(font_id, { x = this._max_x / 2 - 50, y = this._max_y - 815 })
    engine.font.set_scale(font_id, { x = 0.7, y = 0.7 })
    engine.font.set_color(font_id, { x = 0.8, y = 0.8, z = 0.8 })
    engine.font.draw(font_id)
end

function menu.destroy()
    local this = engine.current()

    engine.font.destroy(this._font_id)
    engine.texture.destroy(this._texture_id)
    engine.audio.destroy(this._sound_id)
end
