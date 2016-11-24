# This object handles the internal processing of Atos payment gateway response,
# handling params parsing, request origin verification, success tracking and
# other data extracting tasks
#
module Stall
  module Atos
    class PaymentResponse
      attr_reader :gateway, :params

      def initialize(gateway, params)
        @gateway = gateway
        @params = params
      end

      def transaction_id
        data['transactionReference']
      end

      def success?
        data['responseCode'] == '00'
      end

      # Ensure the response comes from the Gateway by casting the seal from the
      # provided key-value string data and the secret key
      #
      def valid?
        params['Seal'] == Stall::Atos::PaymentParams.calculate_seal_for(params['Data'])
      end

      def data
        @data ||= Stall::Atos::PaymentParams.unserialize(params['Data'])
      end

      private

      # Response code that can be sent from the ATOS gateway. They're not used
      # for now and here just for reference, but could be used some day to
      # implement a way to bubble payment processing errors to the end user.
      #
      def response_code_messages
        @response_code_messages ||= {
          '00' => %(Transaction approuvée ou traitée avec succès),
          '02' => %(Contactez l'émetteur du moyen de paiement),
          '03' => %(Accepteur invalide),
          '04' => %(Conservez le support du moyen de paiement),
          '05' => %(Ne pas honorer),
          '07' => %(Conservez le support du moyen de paiement, conditions spéciales),
          '08' => %(Approuvez après l'identification),
          '12' => %(Transaction invalide),
          '13' => %(Montant invalide),
          '14' => %(Coordonnées du moyen de paiement invalides),
          '15' => %(Émetteur du moyen de paiement inconnu),
          '17' => %(Paiement interrompu par l'acheteur),
          '24' => %(Opération impossible),
          '25' => %(Transaction inconnue),
          '30' => %(Érreur de format),
          '31' => %(Id de l'organisation d'acquisition inconnu),
          '33' => %(Moyen de paiement expiré),
          '34' => %(Suspicion de fraude),
          '40' => %(Fonction non supportée),
          '41' => %(Moyen de paiement perdu),
          '43' => %(Moyen de paiement volé),
          '51' => %(Provision insuffisante ou crédit dépassé),
          '54' => %(Moyen de paiement expiré),
          '56' => %(Moyen de paiement manquant dans le fichier),
          '57' => %(Transaction non autorisée pour ce porteur),
          '58' => %(Transaction interdite au terminal),
          '59' => %(Suspicion de fraude),
          '60' => %(L'accepteur du moyen de paiement doit contacter l'acquéreur),
          '61' => %(Éxcède le maximum autorisé),
          '62' => %(Transaction en attente de confirmation de paiement),
          '63' => %(Règles de sécurité non respectées),
          '65' => %(Nombre de transactions du jour dépassé),
          '68' => %(Réponse non parvenue ou reçue trop tard),
          '75' => %(Nombre de tentatives de saisie des coordonnées du moyen de paiement dépassé 87 Terminal inconnu),
          '90' => %(Arrêt momentané du système),
          '91' => %(Émetteur du moyen de paiement inaccessible),
          '92' => %(La transaction ne contient pas les informations suffisantes pour être redirigées vers l'organisme d'autorisation),
          '94' => %(Transaction dupliquée),
          '96' => %(Mauvais fonctionnement du système),
          '97' => %(Requête expirée: transaction refusée),
          '98' => %(Serveur inaccessible),
          '99' => %(Incident technique)
        }
      end
    end
  end
end
