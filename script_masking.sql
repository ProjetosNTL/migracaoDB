-- Script de Dynamic Data Masking - ISO 27001 / LGPD
-- Gerado automaticamente em 2026-06-02 15:19
-- REVISAR ANTES DE EXECUTAR: remover falsos positivos


-- ========== Schema: Beneficio ==========

-- [CRITICO - LGPD SENSIVEL] valorTotalPlanoSaude (decimal) - 40709 registros
ALTER TABLE [Beneficio].[processaBeneficioDetalhe]
ALTER COLUMN [valorTotalPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalPlanoSaudeBeneficio (decimal) - 40709 registros
ALTER TABLE [Beneficio].[processaBeneficioDetalhe]
ALTER COLUMN [valorTotalPlanoSaudeBeneficio] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Contratacao ==========

-- [CRITICO - LGPD SENSIVEL] atestadoSaudeOcupacional (int) - 1072 registros
ALTER TABLE [Contratacao].[atestadoSaudeOcupacionalUpload]
ALTER COLUMN [atestadoSaudeOcupacional] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] agenciaBanco (varchar) - 1062 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [agenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (varchar) - 407 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 1088 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] codigoCid (varchar) - 23 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [codigoCid] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 1117 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpfConjuge (varchar) - 1071 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [cpfConjuge] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] ctps (bit) - 1086 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [ctps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] dataEmissaoRg (datetime) - 886 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [dataEmissaoRg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] digitoAgenciaBanco (varchar) - 192 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [digitoAgenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoContaBanco (varchar) - 1025 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [digitoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 1118 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] emissorRg (varchar) - 986 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [emissorRg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] fk_banco (int) - 1062 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [fk_banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] localRg (varchar) - 958 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [localRg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] novoCargo (int) - 1075 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [novoCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] outroTelefone (varchar) - 383 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [outroTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] pis (varchar) - 1054 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 1086 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] telefoneCelular (varchar) - 1097 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [telefoneCelular] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneResidencial (varchar) - 149 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [telefoneResidencial] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] verificaCargo (int) - 1098 registros
ALTER TABLE [Contratacao].[candidato]
ALTER COLUMN [verificaCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cpf (varchar) - 403 registros
ALTER TABLE [Contratacao].[candidatoDependente]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] rg (varchar) - 369 registros
ALTER TABLE [Contratacao].[candidatoDependente]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cpf (varchar) - 4 registros
ALTER TABLE [Contratacao].[candidatoFilho]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Contratacao].[candidatoPensaoAlimenticia]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpfCandidato (varchar) - 497 registros
ALTER TABLE [Contratacao].[candidatoUploadContratacao]
ALTER COLUMN [cpfCandidato] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [RESTRITO] email (varchar) - 324 registros
ALTER TABLE [Contratacao].[captacaoRecursoEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailPrincipal (bit) - 304 registros
ALTER TABLE [Contratacao].[captacaoRecursoEmail]
ALTER COLUMN [emailPrincipal] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 419 registros
ALTER TABLE [Contratacao].[captacaoRecursos]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] telefone (varchar) - 403 registros
ALTER TABLE [Contratacao].[captacaoRecursoTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cargo (int) - 1037 registros
ALTER TABLE [Contratacao].[controleFuncionario]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salarioBase (decimal) - 1037 registros
ALTER TABLE [Contratacao].[controleFuncionario]
ALTER COLUMN [salarioBase] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 4 registros
ALTER TABLE [Contratacao].[implementador]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [RESTRITO] telefone (varchar) - 9 registros
ALTER TABLE [Contratacao].[implementador]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [Contratacao].[parametroContrato]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] documentoPlanoSaude (varchar) - 0 registros
ALTER TABLE [Contratacao].[parametroContrato]
ALTER COLUMN [documentoPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] caminhoPlanoSaudePdf (varchar) - 1 registros
ALTER TABLE [Contratacao].[parametroRelatorio]
ALTER COLUMN [caminhoPlanoSaudePdf] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (varchar) - 0 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidadeFuncionario (varchar) - 0 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [cidadeFuncionario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidadeLocalTrabalho (varchar) - 0 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [cidadeLocalTrabalho] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 11 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [RESTRITO] email (varchar) - 1 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] pis (varchar) - 11 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] telefone (varchar) - 11 registros
ALTER TABLE [Contratacao].[preCadastroCandidato]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cargo (int) - 563 registros
ALTER TABLE [Contratacao].[solicitacaoRecursos]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSalario (int) - 403 registros
ALTER TABLE [Contratacao].[solicitacaoRecursos]
ALTER COLUMN [cargoSalario] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] observacaoCargo (varchar) - 495 registros
ALTER TABLE [Contratacao].[solicitacaoRecursos]
ALTER COLUMN [observacaoCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] observacaoPlanoDeSaude (varchar) - 563 registros
ALTER TABLE [Contratacao].[solicitacaoRecursos]
ALTER COLUMN [observacaoPlanoDeSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioBase (decimal) - 562 registros
ALTER TABLE [Contratacao].[solicitacaoRecursos]
ALTER COLUMN [salarioBase] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 5 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosHistorico]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSalario (int) - 5 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosHistorico]
ALTER COLUMN [cargoSalario] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] observacaoCargo (varchar) - 5 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosHistorico]
ALTER COLUMN [observacaoCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] observacaoPlanoDeSaude (varchar) - 5 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosHistorico]
ALTER COLUMN [observacaoPlanoDeSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioBase (decimal) - 5 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosHistorico]
ALTER COLUMN [salarioBase] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosInterno]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salarioBase (varchar) - 0 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosInterno]
ALTER COLUMN [salarioBase] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioDiaria (varchar) - 0 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosInterno]
ALTER COLUMN [salarioDiaria] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioHora (varchar) - 0 registros
ALTER TABLE [Contratacao].[solicitacaoRecursosInterno]
ALTER COLUMN [salarioHora] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargoInteresse (int) - 0 registros
ALTER TABLE [Contratacao].[trabalheConoscoCurriculo]
ALTER COLUMN [cargoInteresse] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Contratacao].[trabalheConoscoCurriculo]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Contratacao].[trabalheConoscoCurriculo]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cargoInteresse (varchar) - 0 registros
ALTER TABLE [Contratacao].[trabalheConoscoCurriculoExperiencia]
ALTER COLUMN [cargoInteresse] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');


-- ========== Schema: Faturamento ==========

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Faturamento].[contrato]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [Faturamento].[dadosPlanilha]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (decimal) - 0 registros
ALTER TABLE [Faturamento].[gastosFuncionarioPlanejado]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salario (decimal) - 0 registros
ALTER TABLE [Faturamento].[gastosFuncionarioReal]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco (varchar) - 0 registros
ALTER TABLE [Faturamento].[importacaoContasPagar]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] pisReter (varchar) - 0 registros
ALTER TABLE [Faturamento].[importacaoContasPagar]
ALTER COLUMN [pisReter] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pisReter (decimal) - 0 registros
ALTER TABLE [Faturamento].[importacaoReceber]
ALTER COLUMN [pisReter] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] encargo (int) - 0 registros
ALTER TABLE [Faturamento].[logEncargo]
ALTER COLUMN [encargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] encargo (int) - 0 registros
ALTER TABLE [Faturamento].[valorPostoEncargo]
ALTER COLUMN [encargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] remuneracao (int) - 0 registros
ALTER TABLE [Faturamento].[valorPostoRemuneracao]
ALTER COLUMN [remuneracao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] remuneracao (int) - 0 registros
ALTER TABLE [Faturamento].[valorPostoRemuneracaoPercentual]
ALTER COLUMN [remuneracao] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Funcionario ==========

-- [CRITICO - LGPD SENSIVEL] atestadoSaudeOcupacional (int) - 2922 registros
ALTER TABLE [Funcionario].[atestadoSaudeOcupacionalDetalhe]
ALTER COLUMN [atestadoSaudeOcupacional] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Funcionario].[auditoriaValeTransporte]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 1073 registros
ALTER TABLE [Funcionario].[contrachequeSalarioMensalista]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CONFIDENCIAL] salarioMensalista (decimal) - 1073 registros
ALTER TABLE [Funcionario].[contrachequeSalarioMensalista]
ALTER COLUMN [salarioMensalista] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 57410 registros
ALTER TABLE [Funcionario].[folhaContracheque]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 650 registros
ALTER TABLE [Funcionario].[folhaContrachequeAdiantamento]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 4749 registros
ALTER TABLE [Funcionario].[folhaContrachequeComplementar]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 7279 registros
ALTER TABLE [Funcionario].[folhaDecimo]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (int) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] ctps (int) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [ctps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pis (int) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salarioFgts (varchar) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [salarioFgts] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioInss (varchar) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [salarioInss] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioLiquido (varchar) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [salarioLiquido] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] serieCtps (int) - 0 registros
ALTER TABLE [Funcionario].[folhaDePagamento]
ALTER COLUMN [serieCtps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cpf (varchar) - 4137 registros
ALTER TABLE [Funcionario].[folhaRendimento]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Funcionario].[importacaoAuditoriaSaude]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] ctps (varchar) - 111 registros
ALTER TABLE [Funcionario].[importacaoFeriasAviso]
ALTER COLUMN [ctps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] numeroCtps (varchar) - 233 registros
ALTER TABLE [Funcionario].[importacaoFeriasAvisoNovo]
ALTER COLUMN [numeroCtps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pis (varchar) - 0 registros
ALTER TABLE [Funcionario].[importacaoPontoEletronico]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] funcionarioCargo (varchar) - 0 registros
ALTER TABLE [Funcionario].[importarAvisoFeriasExportado]
ALTER COLUMN [funcionarioCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] funcionarioSalario (varchar) - 0 registros
ALTER TABLE [Funcionario].[importarAvisoFeriasExportado]
ALTER COLUMN [funcionarioSalario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] remuneracao (varchar) - 0 registros
ALTER TABLE [Funcionario].[importarAvisoFeriasExportado]
ALTER COLUMN [remuneracao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 81 registros
ALTER TABLE [Funcionario].[relatorioParentesco]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 81 registros
ALTER TABLE [Funcionario].[relatorioParentesco]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 81 registros
ALTER TABLE [Funcionario].[relatorioParentesco]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] atestado (int) - 2394 registros
ALTER TABLE [Funcionario].[uploadDocumentoFolhaPontoHistorico]
ALTER COLUMN [atestado] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Implantacao ==========

-- [CONFIDENCIAL] bancoHoras (bit) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] ctps (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [ctps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] dependentePlanoSaude (int) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [dependentePlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] estadoCtps (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [estadoCtps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] periodicidadeAso (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [periodicidadeAso] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] pisPasep (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [pisPasep] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salarioBase (decimal) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [salarioBase] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] serieCtps (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [serieCtps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneResidencia (varchar) - 0 registros
ALTER TABLE [Implantacao].[funcionario]
ALTER COLUMN [telefoneResidencia] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] dependentePlanoSaude (int) - 0 registros
ALTER TABLE [Implantacao].[funcionarioConvenio]
ALTER COLUMN [dependentePlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Mensageria ==========

-- [CRITICO] urgente (bit) - 180 registros
ALTER TABLE [Mensageria].[solicitacao]
ALTER COLUMN [urgente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');


-- ========== Schema: Ntl ==========

-- [RESTRITO] email (varchar) - 2 registros
ALTER TABLE [Ntl].[administradorDenuncia]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] agenciaBanco (varchar) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [agenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco (int) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 11 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] contaBanco (varchar) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [contaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoAgenciaBanco (varchar) - 0 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [digitoAgenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoContaBanco (varchar) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [digitoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] rg (varchar) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] tipoContaBanco (int) - 19 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [tipoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] variacaoBanco (varchar) - 0 registros
ALTER TABLE [Ntl].[alteraInformacoes]
ALTER COLUMN [variacaoBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 18 registros
ALTER TABLE [Ntl].[alteraInformacoesEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 31 registros
ALTER TABLE [Ntl].[alteraInformacoesTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] emailFuncionario (varchar) - 1 registros
ALTER TABLE [Ntl].[atendimentoRotina]
ALTER COLUMN [emailFuncionario] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] codigoBanco (varchar) - 21 registros
ALTER TABLE [Ntl].[banco]
ALTER COLUMN [codigoBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] nomeBanco (varchar) - 21 registros
ALTER TABLE [Ntl].[banco]
ALTER COLUMN [nomeBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 1535 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 1657 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSalario (int) - 698 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [cargoSalario] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] enviarEmail (bit) - 290 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [enviarEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] inicioBancoHoras (datetime) - 324 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [inicioBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioFuncionario (decimal) - 0 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [salarioFuncionario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalDependentePlanoSaude (decimal) - 1654 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [valorTotalDependentePlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalPlanoSaude (decimal) - 1654 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [valorTotalPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalTitularPlanoSaude (decimal) - 1654 registros
ALTER TABLE [Ntl].[beneficioProjeto]
ALTER COLUMN [valorTotalTitularPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSalario (int) - 4267 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [cargoSalario] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] enviarEmail (bit) - 854 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [enviarEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] inicioBancoHoras (datetime) - 2085 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [inicioBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] salarioFuncionario (decimal) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [salarioFuncionario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalDependentePlanoSaude (decimal) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [valorTotalDependentePlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalPlanoSaude (decimal) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [valorTotalPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorTotalTitularPlanoSaude (decimal) - 5613 registros
ALTER TABLE [Ntl].[beneficioProjetoHistorico]
ALTER COLUMN [valorTotalTitularPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco_agencia (int) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [banco_agencia] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] celular (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [celular] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] data_emissao_rg (date) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [data_emissao_rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] ddd_celular (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [ddd_celular] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] digito_serie_ctps (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [digito_serie_ctps] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] nome_banco (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [nome_banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] nome_cargo (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [nome_cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] nome_da_cidade (int) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [nome_da_cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] nomeCidadeRes (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [nomeCidadeRes] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] numero_cargo (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [numero_cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] orgao_emissor_rg (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [orgao_emissor_rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pis (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (decimal) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[cadastroInicial]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] codigoCargoSCI (varchar) - 313 registros
ALTER TABLE [Ntl].[cargo]
ALTER COLUMN [codigoCargoSCI] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (decimal) - 15 registros
ALTER TABLE [Ntl].[cargo]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 153 registros
ALTER TABLE [Ntl].[cargoExameComplementar]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] piso (decimal) - 41 registros
ALTER TABLE [Ntl].[cargoSindicato]
ALTER COLUMN [piso] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargo (int) - 1 registros
ALTER TABLE [Ntl].[cargoSubstituto]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargo (int) - 6 registros
ALTER TABLE [Ntl].[cargoSubstitutoDetalhe]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSubstituto (int) - 6 registros
ALTER TABLE [Ntl].[cargoSubstitutoDetalhe]
ALTER COLUMN [cargoSubstituto] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] agendamentoEmail (bit) - 16 registros
ALTER TABLE [Ntl].[clinica]
ALTER COLUMN [agendamentoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailDeAgendamento (varchar) - 16 registros
ALTER TABLE [Ntl].[clinica]
ALTER COLUMN [emailDeAgendamento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] celular (varchar) - 0 registros
ALTER TABLE [Ntl].[contratoContato]
ALTER COLUMN [celular] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[contratoContato]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[contratoContato]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] cidadeFaturamento (varchar) - 0 registros
ALTER TABLE [Ntl].[contratoFaturamento]
ALTER COLUMN [cidadeFaturamento] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] pisConfisCs (int) - 0 registros
ALTER TABLE [Ntl].[contratoFaturamento]
ALTER COLUMN [pisConfisCs] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoEvento (int) - 0 registros
ALTER TABLE [Ntl].[controleEvento]
ALTER COLUMN [cargoEvento] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 2 registros
ALTER TABLE [Ntl].[coordenadorDenuncia]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[denunciaAcusados]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[denunciaAcusados]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[denunciaApuracao]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[denunciaApuracao]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 2 registros
ALTER TABLE [Ntl].[denunciaPermissao]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] bancoHoras (bit) - 7 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] emailAlteracaoDados (bit) - 123 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailAlteracaoDados] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAso (bit) - 123 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailAso] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAtestadoComprovante (bit) - 123 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailAtestadoComprovante] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailDemissao (bit) - 109 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailDemissao] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailFerias (bit) - 123 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailFerias] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailLtcatPgrPcmso (bit) - 87 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailLtcatPgrPcmso] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailNepotismo (bit) - 108 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailNepotismo] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailProtocoloPonto (int) - 89 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailProtocoloPonto] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailRecrutamento (bit) - 123 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [emailRecrutamento] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] implantacaoBancoHoras (bit) - 0 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [implantacaoBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] imprimeCargo (bit) - 14 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [imprimeCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] periodicidadeAvaliacao (int) - 114 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [periodicidadeAvaliacao] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] recebeEmailSistema (bit) - 14 registros
ALTER TABLE [Ntl].[departamento]
ALTER COLUMN [recebeEmailSistema] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[departamentoEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAlteracaoDados (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailAlteracaoDados] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAso (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailAso] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAtestadoComprovante (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailAtestadoComprovante] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailDemissao (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailDemissao] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailFerias (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailFerias] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailFeriasAgendamento (bit) - 52 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailFeriasAgendamento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailNepotismo (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailNepotismo] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailProtocoloPonto (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailProtocoloPonto] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailRecrutamento (bit) - 561 registros
ALTER TABLE [Ntl].[departamentoResponsavel]
ALTER COLUMN [emailRecrutamento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 1 registros
ALTER TABLE [Ntl].[departamentoTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefonePrincipal (bit) - 1 registros
ALTER TABLE [Ntl].[departamentoTelefone]
ALTER COLUMN [telefonePrincipal] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneWpp (bit) - 1 registros
ALTER TABLE [Ntl].[departamentoTelefone]
ALTER COLUMN [telefoneWpp] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 20 registros
ALTER TABLE [Ntl].[diasUteisPorMunicipio]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 2 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] bloquearIpDivergente (int) - 1 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [bloquearIpDivergente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 6 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] emailProtocoloPonto (int) - 1 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [emailProtocoloPonto] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] implantacaoBancoHoras (bit) - 0 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [implantacaoBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] imprimeCargo (bit) - 2 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [imprimeCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] periodicidadeAvaliacao (int) - 5 registros
ALTER TABLE [Ntl].[empresa]
ALTER COLUMN [periodicidadeAvaliacao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] pergunta (varchar) - 0 registros
ALTER TABLE [Ntl].[empresaChecklist]
ALTER COLUMN [pergunta] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[empresaEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 2 registros
ALTER TABLE [Ntl].[empresaTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefonePrincipal (bit) - 2 registros
ALTER TABLE [Ntl].[empresaTelefone]
ALTER COLUMN [telefonePrincipal] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Ntl].[evento]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 155 registros
ALTER TABLE [Ntl].[fornecedor]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] agenciaBanco (varchar) - 8 registros
ALTER TABLE [Ntl].[fornecedorDadosBancarios]
ALTER COLUMN [agenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoAgenciaBanco (varchar) - 8 registros
ALTER TABLE [Ntl].[fornecedorDadosBancarios]
ALTER COLUMN [digitoAgenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoContaBanco (varchar) - 8 registros
ALTER TABLE [Ntl].[fornecedorDadosBancarios]
ALTER COLUMN [digitoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] fk_banco (int) - 8 registros
ALTER TABLE [Ntl].[fornecedorDadosBancarios]
ALTER COLUMN [fk_banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[fornecedorEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailPrincipal (bit) - 0 registros
ALTER TABLE [Ntl].[fornecedorEmail]
ALTER COLUMN [emailPrincipal] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 29 registros
ALTER TABLE [Ntl].[fornecedorTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefonePrincipal (bit) - 29 registros
ALTER TABLE [Ntl].[fornecedorTelefone]
ALTER COLUMN [telefonePrincipal] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneWpp (bit) - 29 registros
ALTER TABLE [Ntl].[fornecedorTelefone]
ALTER COLUMN [telefoneWpp] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CONFIDENCIAL] agenciaBanco (varchar) - 922 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [agenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco (int) - 790 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 544 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 678 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 1630 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] codigoCid (varchar) - 26 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [codigoCid] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] contaBanco (varchar) - 921 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [contaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 1635 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO - LGPD SENSIVEL] dataCancelamentoPlanoSaude (datetime) - 3 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [dataCancelamentoPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] dataEmissaoRG (datetime) - 1448 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [dataEmissaoRG] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] digitoAgenciaBanco (varchar) - 383 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [digitoAgenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoContaBanco (varchar) - 858 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [digitoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] inicioBancoHoras (datetime) - 22 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [inicioBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] orgaoEmissorRG (varchar) - 1535 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [orgaoEmissorRG] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pisPasep (varchar) - 1611 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [pisPasep] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 1635 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] tipoContaBanco (int) - 1373 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [tipoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] variacaoBanco (varchar) - 104 registros
ALTER TABLE [Ntl].[funcionario]
ALTER COLUMN [variacaoBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpfDependente (varchar) - 439 registros
ALTER TABLE [Ntl].[funcionarioDependente]
ALTER COLUMN [cpfDependente] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] orgaoEmissorDependente (varchar) - 439 registros
ALTER TABLE [Ntl].[funcionarioDependente]
ALTER COLUMN [orgaoEmissorDependente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rgDependente (varchar) - 439 registros
ALTER TABLE [Ntl].[funcionarioDependente]
ALTER COLUMN [rgDependente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cpfDependente (varchar) - 8 registros
ALTER TABLE [Ntl].[funcionarioDependenteHistorico]
ALTER COLUMN [cpfDependente] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] orgaoEmissorDependente (varchar) - 8 registros
ALTER TABLE [Ntl].[funcionarioDependenteHistorico]
ALTER COLUMN [orgaoEmissorDependente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rgDependente (varchar) - 8 registros
ALTER TABLE [Ntl].[funcionarioDependenteHistorico]
ALTER COLUMN [rgDependente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[funcionarioEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] codigoEmail (int) - 71 registros
ALTER TABLE [Ntl].[funcionarioEmailHistorico]
ALTER COLUMN [codigoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 71 registros
ALTER TABLE [Ntl].[funcionarioEmailHistorico]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Ntl].[funcionarioEnderecoHistorico]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] agenciaBanco (varchar) - 246 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [agenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco (int) - 235 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 0 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 585 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] codigoCid (varchar) - 9 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [codigoCid] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] contaBanco (varchar) - 246 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [contaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 585 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO - LGPD SENSIVEL] dataCancelamentoPlanoSaude (datetime) - 0 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [dataCancelamentoPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] dataEmissaoRG (datetime) - 531 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [dataEmissaoRG] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] digitoAgenciaBanco (varchar) - 113 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [digitoAgenciaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] digitoContaBanco (varchar) - 228 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [digitoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] inicioBancoHoras (datetime) - 0 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [inicioBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] orgaoEmissorRG (varchar) - 550 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [orgaoEmissorRG] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pisPasep (varchar) - 583 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [pisPasep] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 585 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] tipoContaBanco (int) - 569 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [tipoContaBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] variacaoBanco (varchar) - 25 registros
ALTER TABLE [Ntl].[funcionarioHistorico]
ALTER COLUMN [variacaoBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Ntl].[funcionarioPensaoAlimenticia]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [RESTRITO] telefone (varchar) - 4074 registros
ALTER TABLE [Ntl].[funcionarioTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] codigoTelefone (int) - 64 registros
ALTER TABLE [Ntl].[funcionarioTelefoneHistorico]
ALTER COLUMN [codigoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefone (varchar) - 64 registros
ALTER TABLE [Ntl].[funcionarioTelefoneHistorico]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] celular (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [celular] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] data_emissao_rg (date) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [data_emissao_rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] orgao_emissor_rg (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [orgao_emissor_rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pis (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] rg (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [rg] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoCadastroFuncionario]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] CPF (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoFerias]
ALTER COLUMN [CPF] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CONFIDENCIAL] bancoHoras (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoVinculoBeneficio]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Ntl].[importacaoVinculoBeneficio]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] numeroCargo (int) - 0 registros
ALTER TABLE [Ntl].[importacaoVinculoBeneficio]
ALTER COLUMN [numeroCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] abateBancoHoras (bit) - 99 registros
ALTER TABLE [Ntl].[lancamento]
ALTER COLUMN [abateBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cpfCnpjEmpregador (varchar) - 10 registros
ALTER TABLE [Ntl].[logRegistroRep]
ALTER COLUMN [cpfCnpjEmpregador] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpfFuncionario (varchar) - 4925 registros
ALTER TABLE [Ntl].[logRegistroRep]
ALTER COLUMN [cpfFuncionario] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO] cpfFuncionarioCadastro (varchar) - 75 registros
ALTER TABLE [Ntl].[logRegistroRep]
ALTER COLUMN [cpfFuncionarioCadastro] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [CRITICO - LGPD SENSIVEL] descontoFolhaPlanoSaude (decimal) - 217 registros
ALTER TABLE [Ntl].[logValoresProjeto]
ALTER COLUMN [descontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorDescontoFolhaPlanoSaude (decimal) - 1 registros
ALTER TABLE [Ntl].[logValoresProjeto]
ALTER COLUMN [valorDescontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] percentualAuxilioSaude (decimal) - 109 registros
ALTER TABLE [Ntl].[logValoresSindicato]
ALTER COLUMN [percentualAuxilioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] percentualBolsaPlanoSaude (decimal) - 118 registros
ALTER TABLE [Ntl].[logValoresSindicato]
ALTER COLUMN [percentualBolsaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorAuxilioSaude (decimal) - 109 registros
ALTER TABLE [Ntl].[logValoresSindicato]
ALTER COLUMN [valorAuxilioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorBolsaPlanoSaude (decimal) - 118 registros
ALTER TABLE [Ntl].[logValoresSindicato]
ALTER COLUMN [valorBolsaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] dataEmailEnviado (datetime) - 0 registros
ALTER TABLE [Ntl].[ordemServico]
ALTER COLUMN [dataEmailEnviado] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailEnviado (bit) - 0 registros
ALTER TABLE [Ntl].[ordemServico]
ALTER COLUMN [emailEnviado] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] corpoEmail (nvarchar) - 1 registros
ALTER TABLE [Ntl].[parametro]
ALTER COLUMN [corpoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (nvarchar) - 1 registros
ALTER TABLE [Ntl].[parametro]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] senha (nvarchar) - 1 registros
ALTER TABLE [Ntl].[parametro]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] corpoEmail (nvarchar) - 3 registros
ALTER TABLE [Ntl].[parametroHistorico]
ALTER COLUMN [corpoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (nvarchar) - 3 registros
ALTER TABLE [Ntl].[parametroHistorico]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] senha (nvarchar) - 3 registros
ALTER TABLE [Ntl].[parametroHistorico]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] manutencaoPredialEmail (bit) - 0 registros
ALTER TABLE [Ntl].[parametroResponsavelSolicitacoes]
ALTER COLUMN [manutencaoPredialEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] realocacaoPessoasEmail (bit) - 0 registros
ALTER TABLE [Ntl].[parametroResponsavelSolicitacoes]
ALTER COLUMN [realocacaoPessoasEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] servicosExternosEmail (bit) - 0 registros
ALTER TABLE [Ntl].[parametroResponsavelSolicitacoes]
ALTER COLUMN [servicosExternosEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[parametroSistema]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] orgaoLicitante (varchar) - 586 registros
ALTER TABLE [Ntl].[pregao]
ALTER COLUMN [orgaoLicitante] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] convenioSaude (int) - 19 registros
ALTER TABLE [Ntl].[produto]
ALTER COLUMN [convenioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 65 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] bloquearIpDivergente (bit) - 38 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [bloquearIpDivergente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 80 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] descontoFolhaPlanoSaude (decimal) - 5 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [descontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] emailProtocoloPonto (int) - 45 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [emailProtocoloPonto] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] enviaEmailFeriasFuncionario (bit) - 57 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [enviaEmailFeriasFuncionario] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] implantacaoBancoHoras (bit) - 0 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [implantacaoBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] imprimeCargo (bit) - 80 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [imprimeCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] periodicidadeAvaliacao (int) - 57 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [periodicidadeAvaliacao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorDescontoFolhaPlanoSaude (decimal) - 1 registros
ALTER TABLE [Ntl].[projeto]
ALTER COLUMN [valorDescontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 191 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSindicato (int) - 191 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [cargoSindicato] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] piso (bit) - 191 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [piso] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] remuneracao (decimal) - 0 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [remuneracao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] requisitosCargo (varchar) - 191 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [requisitosCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (decimal) - 191 registros
ALTER TABLE [Ntl].[projetoCargoSalario]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (int) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargoSindicato (int) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [cargoSindicato] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] codigoCargoSalario (int) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [codigoCargoSalario] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] piso (bit) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [piso] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] requisitosCargo (varchar) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [requisitosCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (decimal) - 636 registros
ALTER TABLE [Ntl].[projetoCargoSalarioHistorico]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 61 registros
ALTER TABLE [Ntl].[projetoContato]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 61 registros
ALTER TABLE [Ntl].[projetoContato]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneRecado (varchar) - 61 registros
ALTER TABLE [Ntl].[projetoContato]
ALTER COLUMN [telefoneRecado] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 25 registros
ALTER TABLE [Ntl].[projetoContatoHistorico]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 25 registros
ALTER TABLE [Ntl].[projetoContatoHistorico]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefoneRecado (varchar) - 25 registros
ALTER TABLE [Ntl].[projetoContatoHistorico]
ALTER COLUMN [telefoneRecado] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] departamentoEmail (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoEmail]
ALTER COLUMN [departamentoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] funcaoEmail (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoEmail]
ALTER COLUMN [funcaoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] nomeEmail (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoEmail]
ALTER COLUMN [nomeEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO - LGPD SENSIVEL] cidadeFaturamento (varchar) - 59 registros
ALTER TABLE [Ntl].[projetoFaturamento]
ALTER COLUMN [cidadeFaturamento] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] pisConfisCs (int) - 52 registros
ALTER TABLE [Ntl].[projetoFaturamento]
ALTER COLUMN [pisConfisCs] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidadeFaturamento (varchar) - 55 registros
ALTER TABLE [Ntl].[projetoFaturamentoHistorico]
ALTER COLUMN [cidadeFaturamento] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] bancoHoras (bit) - 1536 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [bancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] bloquearIpDivergente (bit) - 487 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [bloquearIpDivergente] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 1536 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] descontoFolhaPlanoSaude (decimal) - 77 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [descontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] emailProtocoloPonto (int) - 1446 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [emailProtocoloPonto] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] enviaEmailFeriasFuncionario (bit) - 0 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [enviaEmailFeriasFuncionario] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] implantacaoBancoHoras (bit) - 0 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [implantacaoBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] imprimeCargo (bit) - 1536 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [imprimeCargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] periodicidadeAvaliacao (int) - 1536 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [periodicidadeAvaliacao] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorDescontoFolhaPlanoSaude (decimal) - 1 registros
ALTER TABLE [Ntl].[projetoHistorico]
ALTER COLUMN [valorDescontoFolhaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] departamentoTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefone]
ALTER COLUMN [departamentoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] funcaoTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefone]
ALTER COLUMN [funcaoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] nomeTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefone]
ALTER COLUMN [nomeTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefone (varchar) - 5 registros
ALTER TABLE [Ntl].[projetoTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] codigoTelefone (int) - 0 registros
ALTER TABLE [Ntl].[projetoTelefoneHistorico]
ALTER COLUMN [codigoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] departamentoTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefoneHistorico]
ALTER COLUMN [departamentoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] funcaoTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefoneHistorico]
ALTER COLUMN [funcaoTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] nomeTelefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefoneHistorico]
ALTER COLUMN [nomeTelefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Ntl].[projetoTelefoneHistorico]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] cpf (varchar) - 0 registros
ALTER TABLE [Ntl].[recadastramentoVtUpload]
ALTER COLUMN [cpf] ADD MASKED WITH (FUNCTION = 'partial(3,".***.***-",2)');

-- [RESTRITO] email (varchar) - 1 registros
ALTER TABLE [Ntl].[recuperaSenha]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] desejaMicrofone (bit) - 164 registros
ALTER TABLE [Ntl].[reservaSala]
ALTER COLUMN [desejaMicrofone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] qndMicrofone (int) - 164 registros
ALTER TABLE [Ntl].[reservaSala]
ALTER COLUMN [qndMicrofone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] telefone (varchar) - 3 registros
ALTER TABLE [Ntl].[responsavel]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[responsavelDenuncia]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CONFIDENCIAL] abateBancoHoras (int) - 16 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [abateBancoHoras] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 10 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] observacaoAuxilioSaude (varchar) - 0 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [observacaoAuxilioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] percentualAuxilioSaude (decimal) - 16 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [percentualAuxilioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] percentualBolsaPlanoSaude (decimal) - 17 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [percentualBolsaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorAuxilioSaude (decimal) - 16 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [valorAuxilioSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] valorBolsaPlanoSaude (decimal) - 17 registros
ALTER TABLE [Ntl].[sindicato]
ALTER COLUMN [valorBolsaPlanoSaude] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] cargo (varchar) - 6 registros
ALTER TABLE [Ntl].[sindicatoCargoSalario]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] salario (nvarchar) - 6 registros
ALTER TABLE [Ntl].[sindicatoCargoSalario]
ALTER COLUMN [salario] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Ntl].[sindicatoEmail]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] telefone (varchar) - 8 registros
ALTER TABLE [Ntl].[sindicatoTelefone]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] usuarioEmail (varchar) - 362 registros
ALTER TABLE [Ntl].[tipoSolicitacao]
ALTER COLUMN [usuarioEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (varchar) - 389 registros
ALTER TABLE [Ntl].[usuario]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] restaurarSenha (bit) - 1508 registros
ALTER TABLE [Ntl].[usuario]
ALTER COLUMN [restaurarSenha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senha (varchar) - 1684 registros
ALTER TABLE [Ntl].[usuario]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senhaAnterior (varchar) - 6 registros
ALTER TABLE [Ntl].[usuario]
ALTER COLUMN [senhaAnterior] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] email (varchar) - 621 registros
ALTER TABLE [Ntl].[usuarioHistorico]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] restaurarSenha (bit) - 1925 registros
ALTER TABLE [Ntl].[usuarioHistorico]
ALTER COLUMN [restaurarSenha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senha (varchar) - 1925 registros
ALTER TABLE [Ntl].[usuarioHistorico]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senhaAnterior (varchar) - 155 registros
ALTER TABLE [Ntl].[usuarioHistorico]
ALTER COLUMN [senhaAnterior] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Sat ==========

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[chamado]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] telefoneContato (varchar) - 0 registros
ALTER TABLE [Sat].[chamado]
ALTER COLUMN [telefoneContato] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[cliente]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] corpoEmail (nvarchar) - 0 registros
ALTER TABLE [Sat].[parametro]
ALTER COLUMN [corpoEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] email (nvarchar) - 0 registros
ALTER TABLE [Sat].[parametro]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] senha (nvarchar) - 0 registros
ALTER TABLE [Sat].[parametro]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[relatorioChromebook]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[relatorioDesktopNotebook]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[relatorioImpressora]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] cidade (varchar) - 0 registros
ALTER TABLE [Sat].[relatorioMonitor]
ALTER COLUMN [cidade] ADD MASKED WITH (FUNCTION = 'default()');

-- [RESTRITO] telefone (varchar) - 0 registros
ALTER TABLE [Sat].[relatorioNtl]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [RESTRITO] email (varchar) - 0 registros
ALTER TABLE [Sat].[usuario]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] restauraSenha (bit) - 0 registros
ALTER TABLE [Sat].[usuario]
ALTER COLUMN [restauraSenha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senha (varchar) - 0 registros
ALTER TABLE [Sat].[usuario]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: SaudeSegurancaTrabalho ==========

-- [RESTRITO] emailVencimento (bit) - 1 registros
ALTER TABLE [SaudeSegurancaTrabalho].[atestadoSaudeOcupacionalParametro]
ALTER COLUMN [emailVencimento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail1 (bit) - 1 registros
ALTER TABLE [SaudeSegurancaTrabalho].[atestadoSaudeOcupacionalParametro]
ALTER COLUMN [envioEmail1] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail2 (bit) - 1 registros
ALTER TABLE [SaudeSegurancaTrabalho].[atestadoSaudeOcupacionalParametro]
ALTER COLUMN [envioEmail2] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail3 (bit) - 1 registros
ALTER TABLE [SaudeSegurancaTrabalho].[atestadoSaudeOcupacionalParametro]
ALTER COLUMN [envioEmail3] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailVencimento (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[LTCATParametro]
ALTER COLUMN [emailVencimento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail1 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[LTCATParametro]
ALTER COLUMN [envioEmail1] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail2 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[LTCATParametro]
ALTER COLUMN [envioEmail2] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail3 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[LTCATParametro]
ALTER COLUMN [envioEmail3] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailVencimento (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PCMSOParametro]
ALTER COLUMN [emailVencimento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail1 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PCMSOParametro]
ALTER COLUMN [envioEmail1] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail2 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PCMSOParametro]
ALTER COLUMN [envioEmail2] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail3 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PCMSOParametro]
ALTER COLUMN [envioEmail3] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailVencimento (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PGRParametro]
ALTER COLUMN [emailVencimento] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail1 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PGRParametro]
ALTER COLUMN [envioEmail1] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail2 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PGRParametro]
ALTER COLUMN [envioEmail2] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] envioEmail3 (bit) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[PGRParametro]
ALTER COLUMN [envioEmail3] ADD MASKED WITH (FUNCTION = 'email()');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[ppraClassificacaoRiscos]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] cargo (int) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[ppraHistoricoClassificacaoRiscos]
ALTER COLUMN [cargo] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO - LGPD SENSIVEL] riscosConhecidos (varchar) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[ppraHistoricoLevantamentoRiscosAmbiente]
ALTER COLUMN [riscosConhecidos] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO - LGPD SENSIVEL] riscosConhecidos (varchar) - 0 registros
ALTER TABLE [SaudeSegurancaTrabalho].[ppraLevantamentoRiscosAmbiente]
ALTER COLUMN [riscosConhecidos] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Scf ==========

-- [CONFIDENCIAL] banco (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesas]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] encargos (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesas]
ALTER COLUMN [encargos] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] porcentagemBanco (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesas]
ALTER COLUMN [porcentagemBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CONFIDENCIAL] banco (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesasAutomatico]
ALTER COLUMN [banco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] encargos (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesasAutomatico]
ALTER COLUMN [encargos] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CONFIDENCIAL] porcentagemBanco (decimal) - 0 registros
ALTER TABLE [Scf].[controleDespesasAutomatico]
ALTER COLUMN [porcentagemBanco] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] energiaEletrica (decimal) - 0 registros
ALTER TABLE [Scf].[despesa]
ALTER COLUMN [energiaEletrica] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] pis (decimal) - 0 registros
ALTER TABLE [Scf].[despesa]
ALTER COLUMN [pis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [RESTRITO] telefone (decimal) - 0 registros
ALTER TABLE [Scf].[despesa]
ALTER COLUMN [telefone] ADD MASKED WITH (FUNCTION = 'partial(4,"****-",0)');

-- [CRITICO] retencaoPis (decimal) - 0 registros
ALTER TABLE [Scf].[receita]
ALTER COLUMN [retencaoPis] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] retencaoPisCumulativa (decimal) - 0 registros
ALTER TABLE [Scf].[receita]
ALTER COLUMN [retencaoPisCumulativa] ADD MASKED WITH (FUNCTION = 'partial(2,"*****",1)');

-- [CRITICO] restauraSenha (bit) - 1 registros
ALTER TABLE [Scf].[usuario]
ALTER COLUMN [restauraSenha] ADD MASKED WITH (FUNCTION = 'default()');

-- [CRITICO] senha (varchar) - 2 registros
ALTER TABLE [Scf].[usuario]
ALTER COLUMN [senha] ADD MASKED WITH (FUNCTION = 'default()');


-- ========== Schema: Solicitacao ==========

-- [RESTRITO] email (varchar) - 3965 registros
ALTER TABLE [Solicitacao].[solicitacao]
ALTER COLUMN [email] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAtribuido (varchar) - 3873 registros
ALTER TABLE [Solicitacao].[solicitacao]
ALTER COLUMN [emailAtribuido] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] acompanharEmail (int) - 0 registros
ALTER TABLE [Solicitacao].[solicitacaoAtendimento]
ALTER COLUMN [acompanharEmail] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailAtribuido (varchar) - 0 registros
ALTER TABLE [Solicitacao].[solicitacaoAtendimento]
ALTER COLUMN [emailAtribuido] ADD MASKED WITH (FUNCTION = 'email()');

-- [RESTRITO] emailSolicitante (varchar) - 0 registros
ALTER TABLE [Solicitacao].[solicitacaoAtendimento]
ALTER COLUMN [emailSolicitante] ADD MASKED WITH (FUNCTION = 'email()');

