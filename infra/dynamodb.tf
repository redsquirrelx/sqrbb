# Creacion de la tabla DynamoDB
# Puede ser propiedades o cualquier otro nombre
resource "aws_dynamodb_table" "propiedades" {
    region = "us-east-2"

    name = "Propiedades"
    billing_mode = "PAY_PER_REQUEST"  # Se paga solamente cuando se consume el servicio

    #Configuracion de la llave primaria
    hash_key = "PropiedadID"  # Se puede cambiar por una mas segura

    # Se define el atributo de la llave primaria
    attribute {
        name = "PropiedadID"
        type = "S"  # S: String
    }

    ttl {
        attribute_name = "expire_at"
        enabled = true
    }

    point_in_time_recovery {
        enabled = true
    }

    server_side_encryption {
        enabled = true
        kms_key_arn = null
    }
    
    replica {
        region_name = "us-east-1"
        consistency_mode = "EVENTUAL"
    }
    
    replica {
        region_name = "eu-west-1"
        consistency_mode = "EVENTUAL"
    }

    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
}

# Creacion de la tabla DynamoDB
resource "aws_dynamodb_table" "reservas" {
    region = "us-east-2"

    name = "Reservas"
    billing_mode = "PAY_PER_REQUEST"  # Se paga solamente cuando se consume el servicio

    #Configuracion de la llave primaria
    hash_key = "ReservaID"  # Se puede cambiar por una mas segura

    # Llave de ordenamiento
    range_key = "FechaRegistro"

    # Se define el atributo de la llave primaria
    attribute {
        name = "ReservaID"
        type = "S"  # S: String
    }

    # Se define la llave de ordenamiento
    attribute {
        name = "FechaRegistro"
        type = "N"
    }

    ttl {
        attribute_name = "expire_at"
        enabled = true
    }

    point_in_time_recovery {
        enabled = true
    }

    server_side_encryption {
        enabled = true
        kms_key_arn = null
    }
    
    replica {
        region_name = "us-east-1"
        consistency_mode = "EVENTUAL"
    }

    replica {
        region_name = "eu-west-1"
        consistency_mode = "EVENTUAL"
    }

    stream_enabled = true
    stream_view_type = "NEW_AND_OLD_IMAGES"
}