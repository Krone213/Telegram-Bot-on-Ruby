require 'telegram/bot' #Подключаем gem

TOKEN = 'YOUR_API_TOKEN' #Токен бота, который можно получить в телеграме у BotFather

kb = [ 
Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Идеальный асфальт', callback_data: "0"),
Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Шершавый асфальт/идеальный сухой грунт/бетонные плиты', callback_data: "1"), 
Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Брусчатка/сухой грунт/плохой асфальт', callback_data: "2"), 
Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Песок/мокрый грунт/грязь', callback_data: "3"),
Telegram::Bot::Types::InlineKeyboardButton.new(text: 'Другое', callback_data: "4") 
] 
#Возвращает запросы callback_data
markup_retry = Telegram::Bot::Types::InlineKeyboardMarkup.new(inline_keyboard: kb) 
#Клавиатура с вариантами выбора

weigth = 1 #Инициализация глобальной переменной веса

Telegram::Bot::Client.run(TOKEN) do |bot| #Создание экземпляра бота
    p "Bot launched."
    bot.listen do |message| #Метод, которые переводит бота в режим прослушивания сообщения
        case message #Отлавливаем сообщения 
        when Telegram::Bot::Types::Message #Обработка сообщений
            if message.text == "/start" #Запуск бота
                bot.api.send_message(
                    chat_id: message.chat.id,
                    text: "Здравствуй, #{message.from.first_name}. Введи свой вес.",
                    )
            elsif message.text == "/stop" #Остановка бота 
                bot.api.send_message(
                    chat_id: message.chat.id,
                    text: "Всего хорошего, #{message.from.first_name}!",
                    )
            elsif message.text == "/continue" #Продолжение работы бота
                bot.api.send_message(
                        chat_id: message.chat.id,
                        text: "Отлично! Теперь выбери покрытие местности:",
                        reply_markup: markup_retry
                    )
            else #Прочие сообщения
                begin
                    weigth = Integer(message.text) #Проверка на число
                    bot.api.send_message(
                        chat_id: message.chat.id,
                        text: "Отлично! Теперь выбери покрытие местности:",
                        reply_markup: markup_retry  #Создание клавиатуры с вариантами выбора 
                    )
                rescue #Блок действий, если сообщение не прошло проверку на число
                    bot.api.send_message(
                        chat_id: message.chat.id,
                        text: "Не понимаю тебя, попробуй снова, #{message.from.first_name}.",
                    )
                end
            end
        when Telegram::Bot::Types::CallbackQuery #Обработка запросов
            if message.data == "0"     #Вывод нужного давления при запросе идеального асфальта
                bot.api.send_message(
                    chat_id: message.from.id, 
                    text: "Покрытие местности: идеальный асфальт. Давление в колёсах должно быть 10 атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                    )  
            elsif message.data == "1"  #Вывод нужного давления при запросе: шершавый асфальт/идеальный сухой грунт/бетонные плиты, с учетом веса по формуле.
                bot.api.send_message(
                    chat_id: message.from.id, 
                    text: "Покрытие местности: шершавый асфальт/идеальный сухой грунт/бетонные плиты. Давление в колёсах должно быть "+ String((weigth *  0.052).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                    )  
           elsif message.data == "2"   #Вывод нужного давления при запросе: брусчатка/сухой грунт/плохой асфальт, с учетом веса по формуле.
                bot.api.send_message(
                    chat_id: message.from.id, 
                    text: "Покрытие местности: брусчатка/сухой грунт/плохой асфальт. Давление в колёсах должно быть "+ String((weigth *  0.03).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                    )  
           elsif message.data == "3"   #Вывод нужного давления при запросе: песок/мокрый грунт/грязь, с учетом веса по формуле.
                bot.api.send_message(
                    chat_id: message.from.id, 
                    text: "Покрытие местности: песок/мокрый грунт/грязь. Давление в колёсах должно быть "+ String((weigth *  0.023).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                    )
           else                        #Вывод стандартного давления при запросе: другое.
                bot.api.send_message(  
                    chat_id: message.from.id, 
                    text: "Покрытие местности: другое. Давление в колёсах должно быть 4 атмосферы. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                    )
           end
        end
    end 
end