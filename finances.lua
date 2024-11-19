-- Lua financial balance 
-- Libreria json para guardar archivos 
local json = require("json")
-- Tablas de transicciones, saving y expenses
local transactions = {	
    saving = {},
    expenses = {}
}

-- Variables globales para el balance actual y nombre de usuario
local current = nil
local username = nil
local SAVE_FILE = "finances_data.json" -- File donde se guardarán los datos

-- Función para cargar datos del archivo
-- Lee el archivo JSON y actualiza las variables globales
local function load_data()
    -- Intenta abrir el archivo en modo lectura
    local file = io.open(SAVE_FILE, "r")
    if file then
        -- Si el archivo existe, lee todo su contenido
        local content = file:read("*all")
        file:close()
        
        -- Convierte el JSON a tabla de Lua
        local data = json.decode(content)
        if data then
            transactions = data.transactions
            current = data.current
            username = data.username
            return true
        end
    end
    return false
end

-- Función para guardar datos en el archivo
-- Guarda todas las variables globales en formato JSON
local function save_data()
    -- Crea una estructura con todos los datos a guardar
    local data = {
        transactions = transactions,
        current = current,
        username = username
    }
    
    -- Convierte la tabla a formato JSON
    local content = json.encode(data)
    
    -- Guarda en el archivo en modo escritura
    local file = io.open(SAVE_FILE, "w")
    if file then
        file:write(content)
        file:close()
        return true
    end
    return false
end

-- Función para agregar una nueva transacción
-- Parámetros:
--   added: cantidad de dinero
--   category: tipo de transacción (ahorro o gasto)
--   name: nombre de la transacción
--   description: descripción detallada
local function add_transaction(added, category, name, description)
    if not current then 
        print("No current balance, please add balance")
        return
    end

    -- Se convierte el sring del usuario a valor númerico
    added = tonumber(added)
    
    -- Verificación de balance
    if not added or added <= 0 then 
        print("Amount can't be less than 0")
        return
    end

    -- Procesa transacción según la categoría
    if category == "saving" then
        -- Agrega nuevo ahorro a la lista
        table.insert(transactions.saving, {
            amount = added,
            name = name,
            description = description,
            date = os.date("%Y-%m-%d %H:%M:%S") -- Agregar fecha, el os.date toma la fecha del sistema
        })
        current = current + added
        --                  | Especificadores de formato |
        --                  %.2f - Es para números decimales (floating point), .2 significa que mostrará 2 decimales
        --                  %s - Es para strings (texto)
        print(string.format("Added saving: %.2f - %s - %s", added, name, description))
        -- Guarda los cambios después de agregar el ahorro
        save_data()
    elseif category == "expenses" then -- Otra variante, es como un switch más primitivo
        -- Agrega nuevo gasto a la lista
        table.insert(transactions.expenses, {
            amount = added,
            name = name,
            description = description,
            date = os.date("%Y-%m-%d %H:%M:%S")
        })
        current = current - added
        print(string.format("Added expense: %.2f - %s - %s", added, name, description))
        -- Guarda los cambios después de agregar el gasto
        save_data()
    else
        print("Invalid category, use 'saving' or 'expenses'")
    end
end

-- Función para mostrar todas las transacciones de una categoría específica
local function show_transactions(category)
    local list
    if category == "saving" then
        list = transactions.saving
    elseif category == "expenses" then
        list = transactions.expenses
    else
        print("Invalid category")
        return
    end

    -- Verifica si hay transacciones para mostrar
    if #list == 0 then
        print("No transactions in " .. category)
        return
    end

    -- Muestra todas las transacciones de la categoría seleccionada
    print("\nCurrent " .. category .. " transactions:")
    for i, t in ipairs(list) do
        print(string.format("%d. %s - %.2f - %s - %s", 
            i, t.date, t.amount, t.name, t.description))
    end
end

-- Función para mostrar el resumen financiero
-- Calcula y muestra el balance actual, total de ahorros y gastos
local function show_total()
    if not current then
        print("No current balance")
        return
    end
    
    -- Calcula totales
    local total_savings = 0
    local total_expenses = 0
    
    for _, t in ipairs(transactions.saving) do
        total_savings = total_savings + t.amount
    end
    
    for _, t in ipairs(transactions.expenses) do
        total_expenses = total_expenses + t.amount
    end
    
    -- Muestra el resumen
    print(string.format("\nFinancial Summary:"))
    print(string.format("\tCurrent Balance: %.2f", current))
    print(string.format("\tTotal Savings: %.2f", total_savings))
    print(string.format("\tTotal Expenses: %.2f", total_expenses))
end

-- Función principal que maneja la interfaz de usuario
-- Proporciona un menú interactivo para gestionar las finanzas
local function main()
    -- Intenta cargar datos guardados previamente
    if load_data() then
        print(string.format("Welcome back %s!", username))
    else
        -- Si no hay datos guardados, pide nombre nuevo
        print("Welcome to Financial Control!")
        print("Please enter your name:")
        username = io.read()
        print(string.format("\nWelcome %s!", username))
    end
    
    -- Muestra comandos disponibles
    print("\nCommands available:")
    print("  add saving <amount> <name> <description>")
    print("  add expense <amount> <name> <description>")
    print("  add balance <amount>")
    print("  show saving")
    print("  show expenses")
    print("  show total")
    print("  exit")

    -- Bucle principal del programa
    while true do 
        io.write("\n> ")
        local input = io.read()
        -- Parsea el comando y sus argumentos
        local command, arg1, arg2, arg3, arg4 = input:match("(%w+)%s*(%w*)%s*(%S*)%s*(%S*)%s*(.*)")
        
        -- Procesa los diferentes comandos
        if command == "add" then 
            if arg1 == "balance" then
                -- Actualiza el balance actual
                current = tonumber(arg2)
                if current then
                    print(string.format("Current balance updated to: %.2f", current))
                    -- Guarda los cambios después de actualizar el balance
                    save_data()
                else
                    print("Error: Invalid balance amount")
                end
            elseif arg1 == "saving" or arg1 == "expenses" then
                -- Agrega nueva transacción
                add_transaction(arg2, arg1, arg3, arg4)
            else
                print("Invalid command. Use 'add saving/expense <amount> <name> <description>'")
            end
        elseif command == "show" then
            if arg1 == "saving" or arg1 == "expenses" then
                -- Muestra transacciones de una categoría
                show_transactions(arg1)
            elseif arg1 == "total" then
                -- Muestra resumen financiero
                show_total()
            else
                print("Invalid argument. Use 'show saving/expenses/total'")
            end
        elseif command == "exit" then
            -- Guarda los datos antes de terminar el programa
            save_data()
            -- Termina el programa
            print(string.format("\nGoodbye %s!", username))
            break
        else
            print("Invalid command!")
        end
    end
end

-- Inicia el programa
main()