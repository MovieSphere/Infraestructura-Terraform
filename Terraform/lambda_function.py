def lambda_handler(event, context):
    """
    Función Lambda básica de ejemplo.
    Puedes personalizar esta función según tus necesidades.
    """
    print("Evento recibido:", event)

    return {
        'statusCode': 200,
        'headers': {
            'Content-Type': 'application/json'
        },
        'body': {
            'message': 'Hola desde la función Lambda'
        }
    }