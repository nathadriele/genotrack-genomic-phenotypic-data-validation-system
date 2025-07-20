class ApplicationController < ActionController::API
  rescue_from ActiveRecord::RecordNotFound, with: :record_not_found
  rescue_from ActionController::ParameterMissing, with: :parameter_missing

  private

  def record_not_found(exception)
    render json: { error: 'Registro não encontrado' }, status: :not_found
  end

  def parameter_missing(exception)
    render json: { error: "Parâmetro obrigatório: #{exception.param}" }, status: :bad_request
  end
end
