require 'telegram/bot' #Подключаем gem

TOKEN = '807527008:AAEMk-h2AMSjsSmsgioVMxXeK13rVXJIlJo' #Токен бота, который можно получить в телеграме у BotFather

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

users = Hash[] #Инициализация "словаря"

loop do   #Бесконечный цикл
    begin
    Telegram::Bot::Client.run(TOKEN) do |bot| #Создание экземпляра бота
        p "Bot launched."
        weigth = 1 #Инициализация глобальной переменной веса
        bot.listen do |message| #Метод, которые переводит бота в режим прослушивания сообщения
            Thread.start(message) do |message|  #запускаем работу с потоками
                begin
                case message #Отлавливаем сообщения 
                when Telegram::Bot::Types::Message #Обработка сообщений
                    if message.text == "/start" #Запуск бота
                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: "Здравствуй, #{message.from.first_name}. Введи свой вес.",
                            )
                            users[message.from.id] = 0 #Создаем "сессию" пользователя
                    elsif message.text == "/stop" #Остановка бота 
                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: "Всего хорошего, #{message.from.first_name}!",
                            )
                            users.delete(message.from.id) #Заканчиваем"сессию" пользователя, удаляем данные
                    elsif message.text == "/continue" #Продолжение работы бота
                        bot.api.send_message(
                                chat_id: message.chat.id,
                                text: "Отлично! Теперь выбери покрытие местности:",
                                reply_markup: markup_retry
                            )
                    else #Прочие сообщения
                        begin
                            weigth = Integer(message.text) #Проверка на число
                            if weigth < 20 or weigth > 200
                                bot.api.send_message(
                                    chat_id: message.chat.id,
                                    text: "Введённый вес - недопустимый, попробуй снова!",
                                )
                            else
                            bot.api.send_message(
                                chat_id: message.chat.id,
                                text: "Отлично! Теперь выбери покрытие местности:",
                                reply_markup: markup_retry  #Создание клавиатуры с вариантами выбора 
                            )
                                users[message.from.id] = weigth #Присваиваем вес пользователю
                            end
                        rescue #Блок действий, если сообщение не прошло проверку на число
                            bot.api.send_message(
                                chat_id: message.chat.id,
                                text: "Не понимаю тебя, попробуй снова, #{message.from.first_name}.",
                            )
                        end
                    end
                when Telegram::Bot::Types::CallbackQuery #Обработка запросов
                    case message.data
                    when "0"     #Вывод нужного давления при запросе идеального асфальта
                        bot.api.send_message(
                            chat_id: message.from.id, 
                            text: "Покрытие местности: идеальный асфальт. Давление в колёсах должно быть 10 атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                            )  
                    when "1"  #Вывод нужного давления при запросе: шершавый асфальт/идеальный сухой грунт/бетонные плиты, с учетом веса по формуле.
                        bot.api.send_message(
                            chat_id: message.from.id, 
                            text: "Покрытие местности: шершавый асфальт/идеальный сухой грунт/бетонные плиты. Давление в колёсах должно быть "+ String((users[message.from.id] *  0.052).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                            )  
                    when "2"   #Вывод нужного давления при запросе: брусчатка/сухой грунт/плохой асфальт, с учетом веса по формуле.
                            bot.api.send_message(
                                chat_id: message.from.id, 
                                text: "Покрытие местности: брусчатка/сухой грунт/плохой асфальт. Давление в колёсах должно быть "+ String((users[message.from.id] *  0.03).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                                )  
                    when "3"   #Вывод нужного давления при запросе: песок/мокрый грунт/грязь, с учетом веса по формуле.
                            bot.api.send_message(
                                chat_id: message.from.id, 
                                text: "Покрытие местности: песок/мокрый грунт/грязь. Давление в колёсах должно быть "+ String((users[message.from.id] *  0.023).round(1)) + " атмосфер. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                                )
                    when "4"     #Вывод стандартного давления при запросе: другое.
                            bot.api.send_message(  
                                chat_id: message.from.id, 
                                text: "Покрытие местности: другое. Давление в колёсах должно быть 4 атмосферы. Если хотите продолжить, введите /continue. Если хотите закончить диалог, введите /stop."
                                ) 
                    end
                end
                rescue Exception => error   #Отлавливаем любые ошибки и выводим их
=begin
                    if error == "<NoMethodError: undefined method `*' for nil:NilClass>"
                        bot.api.send_message(
                            chat_id: message.chat.id,
                            text: "Введи для начала вес, #{message.from.first_name}.",
                        )
                    end
=end
                    p error 
                end
            end   
        end 
    end
    rescue Exception => error   #Отлавливаем любые ошибки и выводим их
        p error
    end
end
