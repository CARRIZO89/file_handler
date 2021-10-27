require 'fileutils'
require 'csv'

classified_images = []
sentiments        = []
images_names      = []
sentiments_per_img = []

##################### LEEMOS EL CSV #####################
CSV.foreach('answers.csv') do |row|
  sentiments        << row[1]
  classified_images << [row[1],row[3].split('/').last.inspect]
  images_names      << row[3].split('/').last.inspect
end

##################### LIMPIAMOS LOS ARRAYS #####################
classified_images.shift
#puts classified_images[0]

sentiments.shift
sentiments = sentiments.uniq
#puts sentiments[0]

images_names.shift
images_names = images_names.uniq

##################### MANEJADOR DE IMAGENES #####################
#Nos movemos a la raiz donde crearemos las subcarpetas
#FileUtils.cd('/home/miguel/Documentos/Laburo/image_clasification')
FileUtils.cd('/home/miguel/Documentos/Laburo/file_handler')

#Creamos las carpetas para las imagenes
sentiments.each do |sentiment|
  if Dir.exist?(sentiment)
    puts "{sentiment} already exists"
  else
    Dir.mkdir(sentiment)
  end
end

######### BUSCAMOS LAS IMGS QUE TENEMOS EN NUESTRA PC ##########
#Nos movemos a la carpeta de las imagenes para obtener las mismas
#FileUtils.cd('/home/miguel/Documentos/mafalda/img/objetos/personaje/08')
#Path de las imgs para las pruebas del script '/home/miguel/Documentos/mafalda/img/objetos/personaje/08' y '.../personaje/03'
FileUtils.cd('/home/miguel/Documentos/mafalda/img/mafalda-imgs-personajes-historiestas-03-08')
files = Dir.glob("*")

########## DETERMINAMOS EL SENTIMIENTO DE LA IMAGEN ############
#Como una imagen puede haber sido clasificada con distintos sentimientos
#x los usuarios de la App, debemos determinar cual fue el sentimiento más
#votado para cada img. En caso de haber empate de sentimientos, x el 
#momento ignoramos dicha img con su clasificación


#Agrupamos las imgs clasificadas x nombre de la img
images_names.each do |img_name|
    sentiments_per_img << classified_images.group_by{|x| x[1] == img_name }
end

#Determinamos cual fue el sentimiento más seleccionado para cada img
final_imgs_list = []
sentiments_per_img.each do |sentiment_img|
    quantity_sentimentes_per_img = []
    sentiments.each do |sentiment|
        count = sentiment_img[true].count{|x| x[0] == sentiment}
        if count > 0
           #En este pto ya tenemos todas las respuestas agrupadas x nombres de las imgs. Esto quiere decir q cada grupo
           #tiene el mismo nobre de una imagen pero distintos sentimientos los cuales fueron seleccionados x los usuarios de la APP
           #es x ello q si, la cantidad de resp es maoyor a 0, significa q tiene almenos una respuesta. Entonces, podemos
           #extraer el nombre de la img de dicha resp haciendo lo siguiente: puts sentiment_img[true][0][1]

           quantity_sentimentes_per_img << [count, sentiment, sentiment_img[true][0][1]]
        end
    end
    #En este pto ya tenemos la cantidad de veces q una img fue calificada con
    #un sentimiento en particular. Ahora debemos determinar si hay empate de
    #sentimientos. Es decir, si cada img fue votada la misma cantidad de veces
    #para más de un sentimiento. Para ello, determinamos cual es el
    #sentimiento más votado:
    max_vote = quantity_sentimentes_per_img.max[0]

    #Ahora buscamos si hay más de un sentimiento con la misma cantidad de veces
    #votados comparando con el max_vote q determinamos anteriormente
    repeated_sentiments = quantity_sentimentes_per_img.count{|x| x[0] == max_vote}
    if repeated_sentiments == 1
      final_imgs_list << quantity_sentimentes_per_img.max
    end
end

#De esta forma detectamos si hay duplicados. Estoy hay q adaptarlo al código
#a = [['alegria','img1'],['enojo','img2'],['tristeza','img1'],['alegria','img1'],['enojo','img2'],['alegria','img1']]
#puts a.find_all { |e| a.count{e[0] == 'zxc'} > 1 }



#Movemos las imagenes a la carpeta q corresponda según el sentimiento asociado
files.each do |image|
  final_imgs_list.each do |classified_img|
    image_name = classified_img[2].chomp('"').reverse.chomp('"').reverse
    if image == image_name
      new_image_name = rand(100000).to_s+'_'+image_name
      FileUtils.cp(image, "/home/miguel/Documentos/Laburo/file_handler/#{classified_img[1]}/#{new_image_name}")
    end
  end
end
