--Vistas
USE Enrollment2021
GO

--INFORMACION DE Materias de carrera
CREATE OR ALTER VIEW MATERIAS_MATCARRERAS_CARRERAS AS
SELECT MC.CodeCareerMatter,
		NameM,
		M.Code,
		C.NameC,
		MC.CareerCode,
		MC.Requirement,
		MC.Corequisite		
FROM TBL_Matters M INNER JOIN TBL_CareerMatter MC
ON M.Code = MC.MatterCode INNER JOIN
TBL_Careers C on MC.CareerCode = C.Code

GO
 
--Informacion de materias abiertas

CREATE OR ALTER VIEW MATERIAS_MATABIERTAS_CARRERAS AS
SELECT MA.OpenSubjectsCode, MA.CareerMatterCode,M.NameM,
		M.Code,
		MC.Requirement,
		MA.ProfesorCode,
		--NombreProfesor,
		MA.AulaCode,
		--TipoAula,
		GroupO, Quota, Cost, PeriodO, YearO, Available,		
		--(SELECT NombreCarrera from TBL_Carreras C INNER JOIN TBL_MateriasCarreras MC
		--ON C.CodigoCarrera = MC.CodigoCarrera where MC.CodigoMateria = M.CodigoMateria) AS Carrera,
		(SELECT NameC FROM TBL_Careers C WHERE C.Code = MC.CareerCode) AS NOMBRECARRERA				
FROM TBL_Matters M INNER JOIN TBL_CareerMatter MC
ON M.Code = MC.MatterCode INNER JOIN
TBL_OpenSubjects MA on MC.CodeCareerMatter = MA.CareerMatterCode 
WHERE MA.Available = 1 

GO
 
--Informacion de materias abiertas facturadas

CREATE OR ALTER VIEW MATERIAS_MATABIERTAS_FACTURADAS AS
SELECT MA.OpenSubjectsCode, MA.CareerMatterCode,M.NameM,
		M.Code,
		MC.Requirement,
		MA.ProfesorCode,
		--NombreProfesor,
		MA.AulaCode,
		--TipoAula,
		GroupO, Quota, Cost, PeriodO, YearO, Available,		
		--(SELECT NombreCarrera from TBL_Carreras C INNER JOIN TBL_MateriasCarreras MC
		--ON C.CodigoCarrera = MC.CodigoCarrera where MC.CodigoMateria = M.CodigoMateria) AS Carrera,
		(SELECT NameC FROM TBL_Careers C WHERE C.Code = MC.CareerCode) AS NOMBRECARRERA				
FROM TBL_Matters M INNER JOIN TBL_CareerMatter MC
ON M.Code = MC.MatterCode INNER JOIN
TBL_OpenSubjects MA on MC.CodeCareerMatter = MA.CareerMatterCode


GO
 
--//Materias abiertas a matricular

CREATE OR ALTER VIEW VIEW_MAT_ABIER_MATRICULAR AS
SELECT OpenSubjectsCode,MA.CareerMatterCode,ProfesorCode,AulaCode,GroupO,Quota,Cost,PeriodO,
YearO, 
		M.NameM,M.Code, 
		MC.CareerCode,
		(SELECT NameC FROM TBL_Careers C WHERE C.Code = MC.CareerCode) AS NOMBRECARRERA,
		MC.Requirement,
		MC.Corequisite
FROM TBL_OpenSubjects MA INNER JOIN TBL_CareerMatter MC ON MA.CareerMatterCode = MC.CodeCareerMatter
INNER JOIN TBL_Matters M ON M.Code = MC.MatterCode
WHERE MA.Available = 1 AND PERIODO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD')
AND YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year')

GO

--Vistas detalle de matrícula
CREATE OR ALTER VIEW VIEW_DETALLES_MATRICULA AS
SELECT MA.OpenSubjectsCode,E.License,
	DM.BillNumber,
	COST,
	(SELECT NameM FROM TBL_Matters M INNER JOIN TBL_CareerMatter MC ON
	M.Code = MC.MatterCode INNER JOIN TBL_OpenSubjects MA
	ON MC.CodeCareerMatter = MA.CareerMatterCode WHERE
	MA.OpenSubjectsCode = DM.OpenMatCode) AS NOMBREMATERIA,
	(SELECT Requirement FROM TBL_CareerMatter MC WHERE MC.CodeCareerMatter = MA.CareerMatterCode) AS REQUISITO,
	MA.PeriodO,
	MA.YearO,
	M.DateM,
	E.Discount
FROM TBL_Students E INNER JOIN TBL_Enrollments M
ON E.License = M.Meat INNER JOIN TBL_EnrollmentDetails DM
ON M.NumFact = DM.BillNumber INNER JOIN TBL_OpenSubjects MA 
ON DM.OpenMatCode = MA.OpenSubjectsCode
WHERE MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') 
AND MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD')
AND M.StateFac = 'PEN' AND DM.DetailStatus = 'MAT'

GO

--Detalles de matriculas facturadas
CREATE OR ALTER VIEW VIEW_DETALLES_MATRICULADOS AS
SELECT MA.OpenSubjectsCode,E.License,
	DM.BillNumber,
	COST,
	(SELECT NameM FROM TBL_Matters M INNER JOIN TBL_CareerMatter MC ON
	M.Code = MC.MatterCode INNER JOIN TBL_OpenSubjects MA
	ON MC.CodeCareerMatter = MA.CareerMatterCode WHERE
	MA.OpenSubjectsCode = DM.OpenMatCode) AS NOMBREMATERIA,
	(SELECT Requirement FROM TBL_CareerMatter MC WHERE MC.CodeCareerMatter = MA.CareerMatterCode) AS REQUISITO,
	MA.PeriodO,
	MA.YearO,
	M.DateM,
	E.Discount
FROM TBL_Students E INNER JOIN TBL_Enrollments M
ON E.License = M.Meat INNER JOIN TBL_EnrollmentDetails DM
ON M.NumFact = DM.BillNumber INNER JOIN TBL_OpenSubjects MA 
ON DM.OpenMatCode = MA.OpenSubjectsCode
WHERE MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') 
AND MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD')
AND M.StateFac = 'CAN' --AND DM.DetailStatus = 'MAT'


GO
 
--Vistas SUMA DE COSTOS
CREATE OR ALTER VIEW VIEW_CALCULO_COSTOS AS
SELECT (SELECT License FROM TBL_Students WHERE License = M.Meat) AS CarnetEstudiante,

M.NumFact,(DM.DiscountPercent/100) AS DESCUENTOMATERIA,
(SELECT Cost FROM TBL_OpenSubjects MA WHERE MA.OpenSubjectsCode = DM.OpenMatCode) AS COSTOMATERIA
,Amount,

(SELECT Discount FROM TBL_Students WHERE License = M.Meat) AS DESCUENTO

FROM 
TBL_Enrollments M INNER JOIN TBL_EnrollmentDetails DM 
ON DM.BillNumber = M.NumFact INNER JOIN TBL_OpenSubjects MA
ON DM.OpenMatCode = MA.OpenSubjectsCode
WHERE MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') 
AND MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD')
AND M.StateFac = 'PEN' AND DM.DetailStatus = 'MAT'
GO
--Calculo de costos de facturas canceladas
CREATE OR ALTER VIEW VIEW_CALCULO_COSTOS_FAC AS
SELECT (SELECT License FROM TBL_Students WHERE License = M.Meat) AS CarnetEstudiante,

M.NumFact,(DM.DiscountPercent/100) AS DESCUENTOMATERIA,
(SELECT Cost FROM TBL_OpenSubjects MA WHERE MA.OpenSubjectsCode = DM.OpenMatCode) AS COSTOMATERIA
,Amount,

(SELECT Discount FROM TBL_Students WHERE License = M.Meat) AS DESCUENTO

FROM 
TBL_Enrollments M INNER JOIN TBL_EnrollmentDetails DM 
ON DM.BillNumber = M.NumFact INNER JOIN TBL_OpenSubjects MA
ON DM.OpenMatCode = MA.OpenSubjectsCode
WHERE MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') 
AND MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD')
AND M.StateFac = 'CAN' AND DM.DetailStatus = 'MAT'

GO

--Detalles de matricula para cerrar cursos
CREATE OR ALTER VIEW VIEW_CIERRE_CURSO AS

SELECT ED.BillNumber, S.License,CONCAT(S.NameS, ' ', S.FLastName, ' ', S.SLastName) AS NOMBRE,
ED.FinalNote,ED.DetailStatus,ED.OpenMatCode

FROM TBL_EnrollmentDetails ED INNER JOIN TBL_Enrollments E
ON ED.BillNumber = E.NumFact INNER JOIN TBL_Students S
ON E.Meat = S.License
WHERE E.StateFac = 'CAN'

GO

--PROCEDIMIENTOS ALMACENADOS

GO

--02.Asina el Aula

CREATE or ALTER PROCEDURE SP_AsignarAulaMat
	@ID_MATERIA_ABIERTA INT,
	@ID_AULA SMALLINT,
	@DIA CHAR(1),
	@HORA_INICIO TIME,
	@HORA_FIN TIME,
	@MENSAJE VARCHAR(200) OUT					
AS
/*	

-----------------------------------Control cambios-------------------

-----------------------------------Control cambios----------------*/
/*
*/
DECLARE @ErrMsg AS VARCHAR(200) 
DECLARE @vln_TotalRegistros INT
DECLARE @vln_ContadorCiclo INT
DECLARE @vln_Contador INT
DECLARE @vln_Aula SMALLINT
DECLARE @vlc_Dia CHAR(1)
DECLARE @vld_HoraInicio TIME
DECLARE @vld_HoraFin TIME
DECLARE @vlb_ExisteChoque BIT = 0
DECLARE @vln_Year SMALLINT
DECLARE @vln_Period TINYINT
DECLARE @tmp_Horario TABLE ( 
  id		INT IDENTITY (1, 1), 
  DIA		CHAR(1), 
  HORA_INICIO TIME,
  HORA_FIN TIME) 
/* Iniciar Transacción */
BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA)
		BEGIN
			SET @MENSAJE = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @ID_MATERIA_ABIERTA)
			RETURN -1
		END
	ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM TBL_Aulas WHERE Codigo = @ID_AULA)
				BEGIN
					SET @MENSAJE = CONCAT('ERROR, NO EXISTE AULA CON CÓDIGO ' , @ID_AULA)
					RETURN -1
				END
			ELSE
				BEGIN
					--SI NO TIENE AULA ASIGNADA
					SELECT @vln_Aula = AulaCode, @vln_Year = YearO, @vln_Period = PeriodO
					FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA

					IF @vln_Aula != @ID_AULA OR @vln_Aula IS NULL 
					BEGIN
						INSERT INTO @tmp_Horario--Carga horarios de materia a seleccionar
						SELECT	DIA, StartTime, EndTime
						FROM	TBL_Schedule
						WHERE	OpenSubjectCode = @ID_MATERIA_ABIERTA
	 
						SET @vln_ContadorCiclo = 1 

						SELECT @vln_TotalRegistros = Count(*) 
						FROM   @tmp_Horario 

						SET @vlb_ExisteChoque = 0	

						WHILE @vln_ContadorCiclo <= @vln_TotalRegistros AND @vlb_ExisteChoque = 0
							BEGIN 
								SELECT	@vlc_Dia = DIA,
								@vld_HoraInicio = HORA_INICIO,
								@vld_HoraFin = HORA_FIN
								FROM	@tmp_Horario 
								WHERE	id = @vln_ContadorCiclo 
		
								SELECT	@vln_Contador = COUNT(*)--Compara los horarios
								FROM TBL_OpenSubjects MA 
								INNER JOIN TBL_Schedule H
								ON MA.OpenSubjectsCode = H.OpenSubjectCode
								WHERE	H.DIA = @vlc_Dia AND
								(StartTime <= @vld_HoraFin AND EndTime >=@vld_HoraInicio) AND
								MA.AulaCode = @ID_AULA AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period
								AND MA.Available = 1
								
								IF (@vln_Contador > 0)
									BEGIN
										SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO'
										SET @vlb_ExisteChoque = 1
									END
									SET @vln_ContadorCiclo = @vln_ContadorCiclo + 1 
							END  
					END
					ELSE
						BEGIN
							SELECT @vln_Contador = COUNT(*)
							FROM TBL_OpenSubjects MA 
							INNER JOIN TBL_Schedule H
							ON MA.OpenSubjectsCode = H.OpenSubjectCode
							WHERE	H.DIA = @DIA AND
							(StartTime <= @HORA_FIN AND EndTime >= @HORA_INICIO) AND
							MA.AulaCode = @ID_AULA AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period
							AND MA.Available = 1

							IF (@vln_Contador > 0)
								BEGIN
									SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO'		
									SET @vlb_ExisteChoque = 1
								END
						END
						IF 	@vlb_ExisteChoque = 0
							BEGIN
								BEGIN TRANSACTION ASIGNA_AULA
								UPDATE	TBL_OpenSubjects
									SET		AulaCode = @ID_AULA
									WHERE	OpenSubjectsCode = @ID_MATERIA_ABIERTA		
									SET @MENSAJE = 'AULA ASIGNADA SATISFACTORIAMENTE'								
							END
						ELSE
							BEGIN
									SET @MENSAJE = 'ERROR AL ASIGNAR EL AULA'
									RETURN -1
							END
				END
		END
		/* Confirmar y Completar Transacción */
	COMMIT TRANSACTION ASIGNA_AULA
	RETURN 0
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ASIGNA_AULA
	SELECT @ErrMsg = '[SP_AsignarAulaMat] - ERROR AL ACTUALIZAR DATOS EN MATERIA_ABIERTA.'
	RETURN -1
END CATCH
/*****************************/
/*EJECUTA EL PROCEDIMIENTO*/
GO

--03.Asigna profesor

CREATE or ALTER PROCEDURE SP_AsignarProfesorMateria
	@ID_MATERIA_ABIERTA INT,
	@ID_PROFESOR INT,
	@DIA CHAR(1),
	@HORA_INICIO TIME,
	@HORA_FIN TIME,
	@MENSAJE VARCHAR(500) OUT					
AS
/*
-----------------------------------Control cambios-------------------

-----------------------------------Control cambios----------------*/

DECLARE @ErrMsg AS VARCHAR(500) 
DECLARE @vln_TotalRegistros INT
DECLARE @vln_ContadorCiclo INT
DECLARE @vln_Contador INT   
DECLARE @vlc_Dia CHAR(1)
DECLARE @vld_HoraInicio TIME
DECLARE @vld_HoraFin TIME
DECLARE @vln_Profesor INT
DECLARE @vln_Year SMALLINT
DECLARE @vln_Period TINYINT
DECLARE @vlb_ExisteChoque BIT = 0
DECLARE @tmp_Horario TABLE ( 
  id		INT IDENTITY (1, 1), 
  DIA		CHAR(1), 
  HORA_INICIO TIME,
  HORA_FIN TIME) 
/* Iniciar Transacción */
BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA)
		BEGIN
			SET @MENSAJE = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @ID_MATERIA_ABIERTA)
			RETURN -1
		END
	ELSE
		BEGIN
			IF NOT EXISTS (SELECT Code FROM TBL_Profesors WHERE Code = @ID_PROFESOR)
				BEGIN
					SET @MENSAJE = CONCAT('ERROR, NO EXISTE PROFESOR CON CÓDIGO ' , @ID_PROFESOR)
					RETURN -1
				END
			ELSE
				BEGIN
					SELECT @vln_Profesor = ProfesorCode, @vln_Year = YearO, @vln_Period = PeriodO  
					FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA

					IF @vln_Profesor != @ID_PROFESOR OR @vln_Profesor IS NULL
						BEGIN
							INSERT INTO @tmp_Horario--Carga horarios de materia seleccionada
							SELECT	DIA, StartTime, EndTime
							FROM	TBL_Schedule
							WHERE	OpenSubjectCode = @ID_MATERIA_ABIERTA
	 
							SET @vln_ContadorCiclo = 1 

							SELECT @vln_TotalRegistros = Count(*) 
							FROM   @tmp_Horario 

							SET @vlb_ExisteChoque = 0	

							WHILE @vln_ContadorCiclo <= @vln_TotalRegistros AND @vlb_ExisteChoque = 0
								BEGIN 
									SELECT	@vlc_Dia = DIA,
									@vld_HoraInicio = HORA_INICIO,
									@vld_HoraFin = HORA_FIN
									FROM	@tmp_Horario 
									WHERE	id = @vln_ContadorCiclo 
		
									SELECT	@vln_Contador = COUNT(*)--Compara horarios
									FROM TBL_OpenSubjects MA
									INNER JOIN TBL_Schedule H
									ON MA.OpenSubjectsCode = H.OpenSubjectCode
									WHERE	H.DIA = @vlc_Dia AND
									(StartTime <= @vld_HoraFin AND EndTime >=@vld_HoraInicio) AND
									MA.ProfesorCode = @ID_PROFESOR AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period
									AND MA.Available = 1
							
									IF (@vln_Contador > 0)
										BEGIN
											SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO '		
											SET @vlb_ExisteChoque = 1
										END 
									SET @vln_ContadorCiclo = @vln_ContadorCiclo + 1 
								END  
						END
					ELSE
							BEGIN
								SELECT @vln_Contador = COUNT(*)
								FROM TBL_OpenSubjects MA 
								INNER JOIN TBL_Schedule H
								ON MA.OpenSubjectsCode = H.OpenSubjectCode
								WHERE	H.DIA = @DIA AND
								(StartTime <= @HORA_FIN AND EndTime >= @HORA_INICIO) AND
								MA.ProfesorCode = @ID_PROFESOR AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period
								AND MA.Available = 1--compara solo con materias disponibles 

								IF (@vln_Contador > 0)
									BEGIN
										SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO'		
										SET @vlb_ExisteChoque = 1
									END
							END
						IF 	@vlb_ExisteChoque = 0
						BEGIN
							BEGIN TRANSACTION ASIGNA_PROFESOR
								UPDATE	TBL_OpenSubjects
								SET		ProfesorCode = @ID_PROFESOR
								WHERE	OpenSubjectsCode = @ID_MATERIA_ABIERTA
		
								SET @MENSAJE = 'PROFESOR ASIGNADO SATISFACTORIAMENTE'								
						END
						ELSE 
						BEGIN
							SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO '
							RETURN -1
						END				
				END
		END	
	/* Confirmar y Completar Transacción */
	COMMIT TRANSACTION ASIGNA_PROFESOR
	RETURN 0
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ASIGNA_PROFESOR
	SELECT @ErrMsg = '[SP_AsignarProfesorMateria] - ERROR AL ACTUALIZAR DATOS EN MATERIA_ABIERTA.'
	RETURN -1
END CATCH
/*****************************/
/*EJECUTA EL PROCEDIMIENTO*/
GO

--04.Asignar MODIFICAR horario

CREATE or ALTER PROCEDURE SP_AgregarModificarHorarioMateriaAbierta
	@ID_MATERIA_ABIERTA INT,
	@DIA CHAR,--Nuevo día
	@HORA_INICIO TIME,--Nueva hora
	@HORA_FIN TIME,--Nueva hora
	@MENSAJE VARCHAR(200) OUTPUT					
AS
/*
-----------------------------------Control cambios-------------------

-----------------------------------Control cambios----------------*/

DECLARE @ErrMsg AS VARCHAR(200) 
DECLARE @vln_Contador INT   
DECLARE @vlc_Dia CHAR(1)
DECLARE @vld_HoraInicio TIME
DECLARE @vld_HoraFin TIME
DECLARE @vlb_ExisteChoque BIT = 0
DECLARE @vln_ExisteChoqueProfe INT = 0
DECLARE @vln_ExisteChoqueAula INT = 0
DECLARE @vln_Cod_Prof INT
DECLARE @vln_Retorno INT = -1
DECLARE @vln_Cod_Aula SMALLINT 
DECLARE @vln_Year SMALLINT
DECLARE @vln_Period TINYINT
BEGIN TRY
	BEGIN TRANSACTION ASIGNA_HORARIO
	IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA)
		BEGIN
			SET @MENSAJE = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @ID_MATERIA_ABIERTA)			
		END
	ELSE
		BEGIN
			SELECT @vln_Year = YearO, @vln_Period = PeriodO--Selecciona periodo y año para comparar horarios  
					FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA

			IF NOT EXISTS (SELECT 1 FROM TBL_EnrollmentDetails DM
			INNER JOIN TBL_OpenSubjects MA 
			ON DM.OpenMatCode = MA.OpenSubjectsCode
			WHERE DM.OpenMatCode = @ID_MATERIA_ABIERTA AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period)
				BEGIN		
					--Comprobar que horario no sea igual a uno de los ya asignados
					SELECT	@vln_Contador = COUNT(*)
					FROM TBL_Schedule H INNER JOIN TBL_OpenSubjects MA ON
					H.OpenSubjectCode = MA.OpenSubjectsCode
					WHERE	H.DIA = @Dia AND
					(H.StartTime <= @Hora_Fin AND H.EndTime >=@Hora_Inicio) AND
					H.OpenSubjectCode = @ID_MATERIA_ABIERTA AND MA.YearO = @vln_Year AND MA.PeriodO = @vln_Period
							
					IF (@vln_Contador > 0)
						BEGIN
							SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO '
							SET @vlb_ExisteChoque = 1
						END
				--comprobar si tiene AULA asignada y choque de horario
				SELECT @vln_Cod_Aula = AulaCode FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA
				IF @vln_Cod_Aula IS NOT NULL
					BEGIN						
						EXECUTE @vln_ExisteChoqueAula = [dbo].[SP_AsignarAulaMat] 
									@ID_MATERIA_ABIERTA
									,@vln_Cod_Aula
									,@DIA
									,@HORA_INICIO
									,@HORA_FIN
									,@MENSAJE OUTPUT
					END
				--comprobar si tiene PROFESOR asignado y choque de horario
				SELECT @vln_Cod_Prof = ProfesorCode FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA
				IF @vln_Cod_Prof IS NOT NULL

					BEGIN						
						EXECUTE @vln_ExisteChoqueProfe = [dbo].[SP_AsignarProfesorMateria] 
									@ID_MATERIA_ABIERTA
								  ,@vln_Cod_Prof
								  ,@DIA
								  ,@HORA_INICIO
								  ,@HORA_FIN
								  ,@MENSAJE OUTPUT
					END
					  
				IF 	@vlb_ExisteChoque = 0 AND @vln_ExisteChoqueAula = 0 AND @vln_ExisteChoqueProfe = 0
					BEGIN
						INSERT INTO TBL_Schedule(OpenSubjectCode, DIA, StartTime, EndTime)
						VALUES(@ID_MATERIA_ABIERTA,@DIA,@HORA_INICIO,@HORA_FIN)		
						SET @MENSAJE = 'HORARIO AGREGADO SATISFACTORIAMENTE'
						SET @vln_Retorno = 0
					END	
				ELSE
					BEGIN
						SET @MENSAJE = CONCAT('ERROR, EXISTE CHOQUE DE HORARIO ' , @ID_MATERIA_ABIERTA)
						SET @vln_Retorno = -1
					END		
				END
			ELSE
				BEGIN 
					SET @MENSAJE = CONCAT('ERROR, LA MATERIA POSEE MATRICULAS REGISTRADAS ' , @ID_MATERIA_ABIERTA)					
				END
		END
/* Confirmar y Completar Transacción */
	COMMIT TRANSACTION ASIGNA_HORARIO
	RETURN @vln_Retorno
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ASIGNA_HORARIO
	SELECT @ErrMsg = '[SP_AgregarHorarioMateriaAbierta] - ERROR AL ACTUALIZAR DATOS EN MATERIA_ABIERTA.'
	RETURN -1
END CATCH
/*****************************/
/*EJECUTA EL PROCEDIMIENTO*/
GO

--05.Crea actualiza detalle de matrícula

CREATE OR ALTER PROCEDURE SP_AsignarNota

@NumFactura int, @CodMateriaAbierta int, @NotaFinal decimal(5,2),
@Msj varchar(200) OUTPUT

AS

DECLARE @ErrMsg AS VARCHAR(200)
DECLARE @vlv_NombreMateria VARCHAR(6)

BEGIN TRY
IF EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @CodMateriaAbierta)
	BEGIN
		IF(@NotaFinal = 0)
			BEGIN
				UPDATE TBL_EnrollmentDetails SET FinalNote = @NotaFinal,
				DetailStatus = 'DST' 
				WHERE BillNumber = @NumFactura AND OpenMatCode = @CodMateriaAbierta
			END
		ELSE 
			BEGIN
				IF(@NotaFinal < 70)
					BEGIN
						UPDATE TBL_EnrollmentDetails SET FinalNote = @NotaFinal,
						DetailStatus = 'REP' 
						WHERE BillNumber = @NumFactura AND OpenMatCode = @CodMateriaAbierta
					END
				ELSE 
					IF(@NotaFinal >= 70)
						BEGIN
							UPDATE TBL_EnrollmentDetails SET FinalNote = @NotaFinal,
							DetailStatus = 'APR' 
							WHERE BillNumber = @NumFactura AND OpenMatCode = @CodMateriaAbierta
						END
			END
	END	
ELSE
BEGIN
	SET @Msj = CONCAT('ERROR, NO EXISTE MATERIA ABIERTA CON CÓDIGO: ' , @CodMateriaAbierta)
	RAISERROR(@Msj,16,2)
END
RETURN 0
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ASIGNA_AULA
	SELECT @ErrMsg = '[SP_ActualizaDetalleMatricula] - ERROR AL ACTUALIZAR DATOS EN DETALLE_MATRICULA.'
	RETURN -1
END CATCH

GO

--06.Actualiza la matrícula

CREATE OR ALTER PROCEDURE SP_ActualizaMatricula

@NumFactura int,
@Carne varchar(6), @TipoPago varchar(14), @ComprobantePago varchar(15),
@EstadoFactura char(3), @EstadoMatricula char(3),@Msj varchar(500) OUTPUT

AS

DECLARE @vlv_NombreEstudiante VARCHAR(25)

BEGIN TRY
--Existe el estudiante
IF EXISTS (SELECT 1 FROM TBL_Students WHERE License = @Carne)
	BEGIN
		SELECT	@vlv_NombreEstudiante = NameS + ' ' + FLastName + ' ' + SLastName
			FROM TBL_Students EST
			WHERE License =  @Carne					
		UPDATE TBL_Enrollments SET StateFac = @EstadoFactura,
		StateMat = @EstadoMatricula 
		WHERE NumFact = @NumFactura
		SET @Msj = CONCAT('Matricula actualizado con éxito. Factura: ', @NumFactura , ' Estudiante: ' , @vlv_NombreEstudiante)					
	END	
ELSE
BEGIN	
	SET @Msj = CONCAT('ERROR, NO EXISTE ESTUDIANTE CON CARNÉ: ' , @Carne)
	RAISERROR(@Msj,16,2)
END
RETURN 0
END TRY
BEGIN CATCH
	SELECT @Msj = '[SP_ActualizaMatricula] - ERROR AL ACTUALIZAR DATOS EN MATRICULA.'
	RETURN -999
END CATCH

GO

--07.Eliminar horario

CREATE OR ALTER PROCEDURE SP_ELIMINAR_HORARIO @COD_MAT_ABIERTA INT, @ID INT,
@MSJ VARCHAR(200) OUTPUT

AS

DECLARE @vln_Retorno INT = -1

BEGIN TRY
BEGIN TRANSACTION ELIMINAR_HORARIO
IF NOT EXISTS(SELECT 1 FROM TBL_EnrollmentDetails
			WHERE OpenMatCode = @COD_MAT_ABIERTA)
	BEGIN
		DELETE FROM TBL_Schedule WHERE OpenSubjectCode = @COD_MAT_ABIERTA AND ID= @Id
		SET @MSJ = 'HORARIO ELIMINADO CON ÉXITO'
		SET @vln_Retorno = 0
		--Elimina materia si no tiene horario
		IF NOT EXISTS(SELECT 1 FROM TBL_Schedule WHERE OpenSubjectCode = @COD_MAT_ABIERTA)
			BEGIN
				DELETE FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @COD_MAT_ABIERTA
				SET @MSJ = 'MATERIA ELIMINADA'
				SET @vln_Retorno = 1
			END
	END
COMMIT TRANSACTION ELIMINAR_HORARIO
RETURN @vln_Retorno
END TRY
BEGIN CATCH
	SELECT @MSJ = '[SP_ELIMINAR_HORARIO] - ERROR AL ELIMINAR HORARIO.'
	RETURN -1
END CATCH
GO

--08.Eliminar materia abierta

CREATE OR ALTER PROCEDURE SP_ELIMINAR_MAT_ABIERTA 

@ID_MAT_ABIERTA INT, @MSJ VARCHAR(500) OUTPUT

AS

DECLARE @ErrMsg AS VARCHAR(500) 

BEGIN TRY
	BEGIN TRANSACTION ELIMINAR_MATERIA
		IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MAT_ABIERTA)
			BEGIN
				SET @MSJ = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @ID_MAT_ABIERTA)
					RAISERROR(@MSJ,16,2)
			END
		ELSE
			BEGIN
				--NO PUEDE EXISTIR EL MISMO CÓDIGO DE MATERIA ABIERTA PARA PERIODOS O AÑOS DIFERENTES
				IF EXISTS (SELECT 1 FROM TBL_EnrollmentDetails
				WHERE OpenMatCode = @ID_MAT_ABIERTA AND DetailStatus = 'MAT')
					BEGIN
						SET @MSJ = CONCAT('ERROR, MATERIA MATRICULADA CON CÓDIGO ' , @ID_MAT_ABIERTA)
						RAISERROR(@MSJ,16,2)
					END
				ELSE
					BEGIN
					--Elimina horarios y materia
						DELETE FROM TBL_Schedule WHERE OpenSubjectCode = @ID_MAT_ABIERTA
						DELETE FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MAT_ABIERTA
						SET @MSJ = CONCAT('MATERIA ELIMINADA CON ÉXITO CON CÓDIGO ' , @ID_MAT_ABIERTA)
						COMMIT TRANSACTION ELIMINAR_MATERIA	
						RETURN 0
					END
			END	
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ELIMINAR_MATERIA
	SELECT @MSJ = '[SP_ELIMINAR_MAT_ABIERTA] - ERROR AL ELIMINAR MATERIA_ABIERTA.'
	RETURN -999
END CATCH

GO

--11.Actualiza materias abiertas--aqui se puede establecer en null el aula y profesor

CREATE or ALTER PROCEDURE SP_ActualizaMateriasAbiertas
--Sin Aula ni profesor
@CodMateriaAbierta int,
@CodMateriaCarrera int, @Grupo tinyInt, @Period TINYINT, @_Year SMALLINT, @Cupo tinyInt,@Costo decimal(10,2),
@Disponible bit, @Dia char(1),@HoraInicio Time, @HoraFin Time ,@MSJ varchar(100) out

AS
/*
-----------------------------------Control cambios-------------------

-----------------------------------Control cambios----------------*/
 
DECLARE @vln_TotalRegistros INT
DECLARE @vln_ContadorCiclo INT
DECLARE @vln_Contador INT
DECLARE @vlv_Grupo TINYINT
DECLARE @vln_Period TINYINT
DECLARE @vln_Year SMALLINT
DECLARE @vln_Aula SMALLINT
DECLARE @vlc_Dia CHAR(1)
DECLARE @vld_HoraInicio TIME
DECLARE @vld_HoraFin TIME
DECLARE @vln_Profe INT
DECLARE @vln_Choque INT = -1
DECLARE @vln_Retorno INT = 0
DECLARE @vlb_ExisteChoque BIT = 0
DECLARE @vln_ExisteChoqueProfe INT = 0
DECLARE @vln_ExisteChoqueAula INT = 0
DECLARE @tmp_Horario TABLE ( 
  id		INT IDENTITY (1, 1), 
  DIA		CHAR(1), 
  HORA_INICIO TIME,
  HORA_FIN TIME)
--DECLARE @vln_asignaAula INT

/* Iniciar Transacción */
BEGIN TRY
BEGIN TRANSACTION ActualizaMateriasAbiertas

IF EXISTS (SELECT 1 FROM TBL_CareerMatter WHERE CodeCareerMatter = @CodMateriaCarrera)
	
	BEGIN
		IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @CodMateriaAbierta)
			BEGIN--Crear materia abierta
				IF NOT EXISTS(SELECT 1 FROM TBL_OpenSubjects MA INNER JOIN TBL_CareerMatter MC
				ON MA.CareerMatterCode = MC.CodeCareerMatter
				WHERE MA.CareerMatterCode = @CodMateriaCarrera 
				AND MA.PeriodO = @Period  
				AND MA.YearO = @_Year)
					BEGIN
					
					INSERT INTO TBL_OpenSubjects(CareerMatterCode,GroupO,Quota,Cost,PeriodO,YearO,Available)
					VALUES (@CodMateriaCarrera, 1, @Cupo, @Costo, @Period, @_Year, @Disponible)
					
					SET @CodMateriaAbierta = SCOPE_IDENTITY()

					--Crear horario 
					INSERT INTO TBL_Schedule(OpenSubjectCode, Dia, StartTime, EndTime)
					
					VALUES(@CodMateriaAbierta, @Dia, @HoraInicio, @HoraFin)
					SET @MSJ = CONCAT('MATERIA CREADA CON EXITO. CÓDIGO: ' , @CodMateriaAbierta)
					SET @vln_Retorno = @CodMateriaAbierta
					END
				ELSE
					BEGIN --YA EXISTE MATERIA CARRERA CREADA GRUPO = GRUPO + 1
						SELECT @vlv_Grupo = GroupO FROM TBL_OpenSubjects MA WHERE MA.CareerMatterCode
						= @CodMateriaCarrera AND MA.Periodo = @PERIOD
						AND MA.YearO = @_Year

						SET @vlv_Grupo = @vlv_Grupo + 1 -- ACTUALIZA GRUPO

						print @vlv_Grupo

						INSERT INTO TBL_OpenSubjects(CareerMatterCode,GroupO,Quota,Cost,PeriodO,YearO,Available)
						VALUES (@CodMateriaCarrera, @vlv_Grupo, @Cupo, @Costo, @Period, @_Year, @Disponible)

						print @vlv_Grupo

						SET @CodMateriaAbierta = SCOPE_IDENTITY()--IDENT_CURRENT()

						--Crear horario 
						INSERT INTO TBL_Schedule(OpenSubjectCode, Dia, StartTime, EndTime)
						
						VALUES(@CodMateriaAbierta, @Dia, @HoraInicio, @HoraFin)
						SET @MSJ = CONCAT('MATERIA CREADA CON EXITO. CÓDIGO: ' , @CodMateriaAbierta)
						SET @vln_Retorno = @CodMateriaAbierta
					END
			END
		ELSE--ACTUALIZAR MATERIA ABIERTA					
			BEGIN
				SELECT @vln_Period = PeriodO, @vln_Year = YearO, @vln_Aula = AulaCode,
				@vln_Profe = ProfesorCode 
				FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @CodMateriaAbierta
				
				IF(@vln_Aula IS NOT NULL)--Comprueba que no repita horario de aula al cambiar periodo  
					BEGIN 
						IF @vln_Period != @Period OR @vln_Year != @_Year
							BEGIN
								
								INSERT INTO @tmp_Horario
								SELECT	DIA, StartTime, EndTime
								FROM	TBL_Schedule
								WHERE	OpenSubjectCode = @CodMateriaAbierta
	 
								SET @vln_ContadorCiclo = 1 

								SELECT @vln_TotalRegistros = Count(*) 
								FROM   @tmp_Horario 

								SET @vlb_ExisteChoque = 0	

								WHILE @vln_ContadorCiclo <= @vln_TotalRegistros AND @vlb_ExisteChoque = 0
									BEGIN 
										
										SELECT	@vlc_Dia = DIA,
										@vld_HoraInicio = HORA_INICIO,
										@vld_HoraFin = HORA_FIN
										FROM	@tmp_Horario 
										WHERE	id = @vln_ContadorCiclo 
		
										SELECT	@vln_Contador = COUNT(*)
										FROM TBL_OpenSubjects MA 
										INNER JOIN TBL_Schedule H
										ON MA.OpenSubjectsCode = H.OpenSubjectCode
										WHERE	H.DIA = @vlc_Dia AND
										(StartTime <= @vld_HoraFin AND EndTime >=@vld_HoraInicio) AND
										MA.AulaCode = @vln_Aula AND MA.YearO = @_Year AND MA.PeriodO = @Period
										
										IF (@vln_Contador > 0)
											BEGIN
												SET @MSJ = 'EXISTE CHOQUE DE HORARIO'		
												SET @vlb_ExisteChoque = 1
											END
										SET @vln_ContadorCiclo = @vln_ContadorCiclo + 1 
									END  

								IF 	@vlb_ExisteChoque = 0
									BEGIN
										SET @MSJ = 'AULA ASIGNADA SATISFACTORIAMENTE'
									END
								ELSE
									BEGIN
										SET @MSJ = 'ERROR AL ASIGNAR EL AULA'
										SET @vln_Retorno = -1
										SET @vln_ExisteChoqueAula = -1
									END
							END
					END

				--Choque de horario en periodo y año profesor

				IF(@vln_Profe IS NOT NULL AND @vln_Retorno = 0)--Comprueba que no repita horario de profesor al cambiar periodo   
					BEGIN 
						IF @vln_Period != @Period OR @vln_Year != @_Year
							BEGIN
								
								INSERT INTO @tmp_Horario
								SELECT	DIA, StartTime, EndTime
								FROM	TBL_Schedule
								WHERE	OpenSubjectCode = @CodMateriaAbierta
	 
								SET @vln_ContadorCiclo = 1 

								SELECT @vln_TotalRegistros = Count(*) 
								FROM   @tmp_Horario 

								SET @vlb_ExisteChoque = 0	

								WHILE @vln_ContadorCiclo <= @vln_TotalRegistros AND @vlb_ExisteChoque = 0
									BEGIN 
										SELECT	@vlc_Dia = DIA,
										@vld_HoraInicio = HORA_INICIO,
										@vld_HoraFin = HORA_FIN
										FROM	@tmp_Horario 
										WHERE	id = @vln_ContadorCiclo 
		
										SELECT	@vln_Contador = COUNT(*)
										FROM TBL_OpenSubjects MA 
										INNER JOIN TBL_Schedule H
										ON MA.OpenSubjectsCode = H.OpenSubjectCode
										WHERE	H.DIA = @vlc_Dia AND
										(StartTime <= @vld_HoraFin AND EndTime >=@vld_HoraInicio) AND
										MA.ProfesorCode = @vln_Profe AND MA.YearO = @_Year AND MA.PeriodO = @Period
										
										IF (@vln_Contador > 0)
											BEGIN
												SET @MSJ = 'EXISTE CHOQUE DE HORARIO'		
												SET @vlb_ExisteChoque = 1
											END
										SET @vln_ContadorCiclo = @vln_ContadorCiclo + 1 
									END  

								IF 	@vlb_ExisteChoque = 0
									BEGIN
										SET @MSJ = 'AULA ASIGNADA SATISFACTORIAMENTE'								
									END
								ELSE
									BEGIN
										SET @MSJ = 'ERROR AL ASIGNAR EL AULA'
										SET @vln_Retorno = -1
										SET @vln_ExisteChoqueProfe = -1
									END
							END
					END

				if( @vln_ExisteChoqueAula = 0 AND @vln_ExisteChoqueProfe = 0 
					AND NOT EXISTS (SELECT 1 FROM TBL_EnrollmentDetails WHERE OpenMatCode = @CodMateriaAbierta))
					BEGIN--Actualiza periodo y año si no hay choque
						UPDATE TBL_OpenSubjects SET PeriodO = @Period, 
						YearO = @_Year WHERE OpenSubjectsCode = @CodMateriaAbierta
					END
				
				UPDATE TBL_OpenSubjects SET 
				Quota=@Cupo,Cost=@Costo, Available=@Disponible
				WHERE OpenSubjectsCode = @CodMateriaAbierta
				SET @MSJ = CONCAT('ACTUALIZADA CON EXITO.CÓDIGO: ' , @CodMateriaAbierta)
			END
	END				
ELSE
	BEGIN--NO EXISTE MATERIA CARRERA
		SET @MSJ = CONCAT('ERROR, NO EXISTE MATERIA CARRERA CON CÓDIGO ' , @CodMateriaCarrera)
		SET @vln_Retorno = -1							
	END
	COMMIT TRANSACTION
	RETURN @vln_Retorno
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ActualizaMateriasAbiertas
	SELECT @MSJ = '[SP_ActualizaMateriasAbiertas] - ERROR AL ACTUALIZAR DATOS EN MATERIA_ABIERTA.'
	RETURN -1
END CATCH

GO

--12.Actualiza aulas

CREATE OR ALTER PROCEDURE SP_ActualizaAulas

@Codigo smallint, @Tipo varchar(11), @Numero tinyInt, @Capacidad tinyint, @Msj varchar(200) OUTPUT

AS 
BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM TBL_Aulas WHERE Codigo = @Codigo)
	BEGIN
	INSERT INTO TBL_Aulas(Tipo,Numero, Capacidad)
	VALUES (@Tipo,@Numero,@Capacidad)
	SET @Codigo = SCOPE_IDENTITY()
	SET @Msj = CONCAT('Aula insertada con éxito. Código: ', @Codigo )
	RETURN 0
	END
ELSE
	UPDATE TBL_Aulas SET Tipo = @Tipo, Numero = @Numero, Capacidad = @Capacidad WHERE Codigo = @Codigo
	SET @Msj = CONCAT('Aula actualizada con éxito. Código: ', @Codigo )
RETURN 0
END TRY
BEGIN CATCH
	RETURN -999
END CATCH
GO

--14.Actualiza materias

CREATE OR ALTER PROCEDURE SP_ActualizaMaterias

@Codigo char(6), @Nombre varchar(100), @Creditos tinyInt, @Msj varchar(200) OUTPUT

AS
BEGIN TRY
IF NOT EXISTS (SELECT 1 FROM TBL_Matters WHERE Code = @Codigo)
	
	BEGIN
		INSERT INTO TBL_Matters(Code, NameM, Credits)
		VALUES (@Codigo,@Nombre,@Creditos)
		SET @Msj = CONCAT('Materia insertada con éxito. Código: ', @Codigo )
		RETURN 0
	END
	
ELSE
	
	BEGIN
		UPDATE TBL_Matters SET NameM = @Nombre, Credits = @Creditos WHERE Code = @Codigo
		SET @Msj = CONCAT('Materia actualizada con éxito. Código: ', @Codigo )
		RETURN 0
	END
	
END TRY
BEGIN CATCH
	SET @Msj = 'ERROR AL ACTUALIZAR MATERIA'
	RETURN -1
END CATCH

GO

--15.Comprobar choque de horarios en matrícula
CREATE or ALTER PROCEDURE SP_Comp_Horario_Matriculas
	@ID_MATERIA_ABIERTA INT,
	@CARNE VARCHAR(6),
	@MENSAJE VARCHAR(500) OUT					
AS
/*
-----------------------------------Control cambios-------------------

-----------------------------------Control cambios----------------*/

DECLARE @ErrMsg AS VARCHAR(500) 
DECLARE @vln_TotalRegistros INT
DECLARE @vln_ContadorCiclo INT
DECLARE @vln_Contador INT   
DECLARE @vlc_Dia CHAR(1)
DECLARE @vld_HoraInicio TIME
DECLARE @vld_HoraFin TIME
DECLARE @vln_Cod_Mat_Abi INT
DECLARE @vlb_ExisteChoque BIT
DECLARE @vln_Retorno INT = -1
DECLARE @tmp_Horario TABLE ( 
  id		INT IDENTITY (1, 1), 
  DIA		CHAR(1), 
  HORA_INICIO TIME,
  HORA_FIN TIME) 
/* Iniciar Transacción */
BEGIN TRY
	IF NOT EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_MATERIA_ABIERTA)
		BEGIN
			SET @MENSAJE = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @ID_MATERIA_ABIERTA)
			RAISERROR(@MENSAJE,16,2)
		END
	ELSE
		BEGIN
			IF NOT EXISTS (SELECT 1 FROM TBL_Students WHERE License = @CARNE)
				BEGIN
					SET @MENSAJE = CONCAT('ERROR, NO EXISTE ESTUDIANTE CON CARNÉ ', @CARNE)
					RAISERROR(@MENSAJE,16,2)
				END
			ELSE
				BEGIN
					INSERT INTO @tmp_Horario
					SELECT	DIA, StartTime, EndTime
					FROM	TBL_Schedule
					WHERE	OpenSubjectCode = @ID_MATERIA_ABIERTA
	 
					SET @vln_ContadorCiclo = 1 

					SELECT @vln_TotalRegistros = Count(*) 
					FROM   @tmp_Horario 

					SET @vlb_ExisteChoque = 0	

					WHILE @vln_ContadorCiclo <= @vln_TotalRegistros AND @vlb_ExisteChoque = 0
						BEGIN 
							SELECT	@vlc_Dia = DIA,
							@vld_HoraInicio = HORA_INICIO,
							@vld_HoraFin = HORA_FIN
							FROM	@tmp_Horario 
							WHERE	id = @vln_ContadorCiclo 
		
							SELECT	@vln_Contador = COUNT(*)
							FROM TBL_Enrollments M  
							INNER JOIN TBL_EnrollmentDetails DM
							ON M.NumFact = DM.BillNumber INNER JOIN
							TBL_OpenSubjects MA 
							ON DM.OpenMatCode = MA.OpenSubjectsCode
							INNER JOIN TBL_Schedule H
							ON MA.OpenSubjectsCode = H.OpenSubjectCode
							WHERE H.DIA = @vlc_Dia AND
							(StartTime <= @vld_HoraFin AND EndTime >=@vld_HoraInicio)
							AND M.Meat = @CARNE
							AND MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues
							WHERE DATO = 'Year') AND MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues
							WHERE DATO = 'PERIOD')
							
							IF (@vln_Contador > 0)
								BEGIN
									SET @MENSAJE = 'EXISTE CHOQUE DE HORARIO CON '											
									SET @vlb_ExisteChoque = 1
									RAISERROR(@MENSAJE,16,2)
								END 
								SET @vln_ContadorCiclo = @vln_ContadorCiclo + 1 
						END  
	  
						IF 	@vlb_ExisteChoque = 0
							BEGIN		
								SET @MENSAJE = 'MATRICULA ASIGNADA SATISFACTORIAMENTE'
								set @vln_Retorno = 0
							END
						
				END
		END	
RETURN @vln_Retorno
END TRY
BEGIN CATCH	
	SELECT @ErrMsg = '[SP_Comp_Horario_Matriculas] - ERROR AL CREAR MATRÍCULA.'
	RETURN -1
END CATCH
GO

--16.Eliminar detalles de matrícula

CREATE OR ALTER PROCEDURE SP_ELIMINAR_DET_MATRICULA @FAC INT, @COD_MAT INT, @MSJ VARCHAR(500) OUT AS

DECLARE @vlt_Fecha_Matricula DATETIME
DECLARE @vln_Dia_Retiro INT 
DECLARE @vln_Retorno INT = -1 

BEGIN TRY
	BEGIN TRANSACTION ELIMINAR_DET
		IF NOT EXISTS(SELECT 1 FROM TBL_EnrollmentDetails DM WHERE DM.BillNumber = @FAC 
			AND DM.OpenMatCode = @COD_MAT)
			BEGIN
				SET @MSJ = CONCAT('NO EXISTE FACTURA: ',@FAC)
			END
		ELSE
			BEGIN
				SELECT @vlt_Fecha_Matricula = DateM FROM TBL_Enrollments 
				WHERE NumFact = @FAC
				SET @vln_Dia_Retiro = DATEDIFF(DAY , @vlt_Fecha_Matricula , getdate())

				IF @vln_Dia_Retiro < 15
					BEGIN
						DELETE FROM TBL_EnrollmentDetails WHERE BillNumber = @FAC AND OpenMatCode = @COD_MAT
						SET @MSJ = 'MATERIA ELIMINADA'
						Set @vln_Retorno = 0
						IF NOT EXISTS(SELECT 1 FROM TBL_EnrollmentDetails DM WHERE DM.BillNumber = @FAC)
							BEGIN
								DELETE FROM TBL_Enrollments WHERE NumFact = @FAC
								SET @MSJ = CONCAT('FACTURA NÚMERO : ',@FAC,' ELIMINADA CON ÉXITO')
							END
					END
				ELSE
					SET @MSJ = CONCAT('NO SE PUEDE ELIMINAR FACTURA : ',@FAC,' YA HAN PASADO LOS DIAS PARA RETIRAR MATRICULA')
			END
	COMMIT TRANSACTION ELIMINAR_DET
	RETURN @vln_Retorno
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ELIMINAR_DET
	SELECT @MSJ = '[SP_ELIMINAR_DET_MATRICULA] - ERROR AL ELIMINAR MATERIA.'
	RETURN -1
END CATCH

GO

--17.Matricular

CREATE OR ALTER PROCEDURE SP_MATRICULAR @CARNE VARCHAR(6),
@COD_MAT_ABI INT,@MSJ VARCHAR(500) OUT

AS

DECLARE @ErrMsg AS VARCHAR(500)
DECLARE @vlv_Codigo VARCHAR(6)
DECLARE @vln_NumFactura INT
DECLARE @vln_Cupo INT
DECLARE @vln_Retorno INT = 0
DECLARE @vln_Cod_Mat_Abi_Req INT
DECLARE @vln_Choque_Horario INT = -1
DECLARE @vlb_CumpleRequisitos BIT = 1
DECLARE @vln_Descuento_Est DECIMAL(5,2)
DECLARE @vln_Monto DECIMAL(10,2)

BEGIN TRY
	BEGIN TRANSACTION MATRICULAR
		IF NOT EXISTS(SELECT 1 FROM TBL_Students WHERE License = @CARNE)
			BEGIN
				SET @MSJ = CONCAT('ERROR, NO EXISTE ESTUDIANTE CON CARNÉ ' , @CARNE)
				SET @vln_Retorno = -1
			END	
		ELSE
			BEGIN 
				IF NOT EXISTS(SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @COD_MAT_ABI)
					BEGIN
						SET @MSJ = CONCAT('ERROR, NO EXISTE MATERIA CON CÓDIGO ' , @COD_MAT_ABI)
						SET @vln_Retorno = -1
					END
				ELSE
					SELECT @vlv_Codigo = code from TBL_Matters M inner join TBL_CareerMatter CM
					on M.Code = CM.MatterCode Inner join TBL_OpenSubjects OS 
					on CM.CodeCareerMatter = OS.CareerMatterCode
					where os.OpenSubjectsCode = @COD_MAT_ABI
					--Comprobar que no haya matriculado ese curso
					IF EXISTS (SELECT 1 from TBL_Enrollments E inner join TBL_EnrollmentDetails ED 
					on E.NumFact = ED.BillNumber inner join TBL_OpenSubjects OS
					on ED.OpenMatCode = oS.OpenSubjectsCode inner join TBL_CareerMatter CM 
					on OS.CareerMatterCode = CM.CodeCareerMatter 
					where cm.MatterCode = @vlv_Codigo AND PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Period')
					AND YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') AND E.Meat = @CARNE)
						BEGIN
							SET @MSJ = CONCAT('ERROR, MATERIA MATRICULADA ' , @COD_MAT_ABI)
							SET @vln_Retorno = -1
						END
					ELSE
						BEGIN

							EXECUTE @vln_Choque_Horario = [dbo].[SP_Comp_Horario_Matriculas] @COD_MAT_ABI,@CARNE,@MSJ OUTPUT
					
							IF @vln_Choque_Horario = 0
								BEGIN
								--OBTIENE REQUISITO	
									SET @vlv_Codigo = NULL
									(SELECT @vlv_Codigo = Requirement FROM TBL_CareerMatter MC INNER JOIN 
									TBL_OpenSubjects MA ON MC.CodeCareerMatter = MA.CareerMatterCode 
									WHERE MC.Requirement IS NOT NULL AND MA.OpenSubjectsCode = @COD_MAT_ABI)
									IF (@vlv_Codigo IS NOT NULL)
										BEGIN
											--OBTIENE COD_MAT_ABIE DEL REQUISITO
									
											SELECT @vln_Cod_Mat_Abi_Req = MA.OpenSubjectsCode FROM TBL_OpenSubjects MA 
											INNER JOIN TBL_CareerMatter MC
											ON MA.CareerMatterCode = MC.CodeCareerMatter WHERE MC.MatterCode = @vlv_Codigo
									
											--VERIFICA SI APROBO O MATRICULO
											IF NOT EXISTS (SELECT 1 FROM TBL_EnrollmentDetails DM INNER JOIN TBL_Enrollments M
											ON DM.BillNumber = M.NumFact INNER JOIN TBL_Students E 
											ON M.Meat = E.License WHERE (DM.DetailStatus = 'APR' OR
											DM.DetailStatus = 'MAT') AND DM.OpenMatCode = @vln_Cod_Mat_Abi_Req AND
											M.Meat = @CARNE)
												BEGIN				
													SET @vlb_CumpleRequisitos = 0
												END
										END
									ELSE
									print @vlb_CumpleRequisitos
									IF(@vlb_CumpleRequisitos = 1)
										BEGIN
											SELECT @vln_Cupo = COUNT(1) FROM TBL_EnrollmentDetails WHERE OpenMatCode = @COD_MAT_ABI
											AND DetailStatus = 'MAT'
									
											IF(@vln_Cupo < (SELECT Quota FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @COD_MAT_ABI))
											--COMPROBAR MATRICULA EN AÑO Y PERIODO
												BEGIN
													IF EXISTS (SELECT 1 FROM TBL_Enrollments M INNER JOIN TBL_EnrollmentDetails DM
													ON M.NumFact = DM.BillNumber INNER JOIN TBL_OpenSubjects MA ON
													DM.OpenMatCode = MA.OpenSubjectsCode
													WHERE StateFac = 'CAN' AND Meat = @CARNE AND
													MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD') AND
													MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year'))
														BEGIN 
															SET @MSJ = 'ERROR, ESTUDIANTE YA POSEE MATRICULA EN ESTE PERIODO Y AÑO'
															SET @vln_Retorno = -1
														END
													ELSE
														BEGIN 
															IF EXISTS(SELECT M.NumFact FROM TBL_Enrollments M INNER JOIN TBL_EnrollmentDetails DM
															ON M.NumFact = DM.BillNumber INNER JOIN TBL_OpenSubjects MA ON
															DM.OpenMatCode = MA.OpenSubjectsCode WHERE 
															MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'PERIOD') 
															AND MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year')  
															AND M.Meat = @CARNE)
																BEGIN
																	SELECT @vln_NumFactura = M.NUMFACT FROM TBL_Enrollments M INNER JOIN TBL_EnrollmentDetails DM
																	ON M.NumFact = DM.BillNumber INNER JOIN TBL_OpenSubjects MA ON
																	MA.OpenSubjectsCode = DM.OpenMatCode WHERE 
																	MA.PeriodO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Period') 
																	AND MA.YearO = (SELECT VALOR FROM TBL_ReferenceValues WHERE DATO = 'Year') 
																	AND M.Meat = @CARNE
															
																	--DESCUENTO ESTUDIANTE
																	SELECT @vln_Descuento_Est = Discount FROM TBL_Students WHERE License = @CARNE

																	INSERT INTO TBL_EnrollmentDetails(BillNumber,OpenMatCode,DiscountPercent)
																	VALUES(@vln_NumFactura,@COD_MAT_ABI,@vln_Descuento_Est)
																	UPDATE TBL_Students SET StateS = 'ACT' WHERE License = @CARNE
																	SET @MSJ = CONCAT('MATRICULA Actualizada CON ÉXITO. FACTURA: ' , @vln_NumFactura)
																END
															ELSE
																BEGIN	
															
																	SELECT @vln_Descuento_Est = Discount FROM TBL_Students WHERE License = @CARNE
																	SELECT @vln_Monto = VALOR FROM TBL_ReferenceValues WHERE DATO = 'CostEnroll'
																	INSERT INTO TBL_Enrollments(Meat,Amount)
																	VALUES(@CARNE,@vln_Monto)
																	SET @vln_NumFactura = SCOPE_IDENTITY()
																	INSERT INTO TBL_EnrollmentDetails(BillNumber,OpenMatCode,DiscountPercent)
																	VALUES(@vln_NumFactura,@COD_MAT_ABI,@vln_Descuento_Est)
															
																	UPDATE TBL_Students SET StateS = 'ACT' WHERE License = @CARNE
																	SET @MSJ = CONCAT('MATRICULA CON ÉXITO. FACTURA: ' , @vln_NumFactura)
																END
														END
													END
												ELSE
													BEGIN
														SET @MSJ = CONCAT('ERROR, NO HAY CUPO DIPONIBLE EN MATERIA CON CÓDIGO ' , @COD_MAT_ABI)
														SET @vln_Retorno = -1
													END
											END
									ELSE
										BEGIN
											SET @MSJ = CONCAT('ERROR, ESTUDIANTE NO CUMPLE CON REQUISITO ' , @vlv_Codigo)
											SET @vln_Retorno = -1
										END
								END
							ELSE
								BEGIN
									SET @MSJ = 'ERROR, EXISTE CHOQUE DE HORARIO' 
									SET @vln_Retorno = -1
								END

						END
					
			END
	COMMIT TRANSACTION MATRICULAR
	RETURN @vln_Retorno
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION MATRICULAR
	SELECT @ErrMsg = '[SP_MATRICULAR] - ERROR AL CREAR MATRICULA.'
	RETURN -1
END CATCH

GO

--18.Eliminar aula
CREATE OR ALTER PROCEDURE SP_DeleteAulas @Codigo SMALLINT,@MSJ VARCHAR(500) OUT AS

DECLARE @vln_Retorno INT = -1

BEGIN TRY
	BEGIN TRANSACTION ELIMINAR_AULA
		IF EXISTS(SELECT 1 FROM TBL_OpenSubjects MA WHERE MA.AulaCode = @Codigo 
			AND MA.Available = 1)
			BEGIN
				SET @MSJ = 'ERROR AULA ASIGNADA, NO SE PUEDE ELIMINAR'
			END
		ELSE
			BEGIN
				DELETE FROM TBL_Aulas WHERE Codigo = @Codigo
				SET @MSJ = 'AULA ELIMINADA CON ÉXITO'
				SET @vln_Retorno = 0
			END
	COMMIT TRANSACTION ELIMINAR_AULA
	RETURN @vln_Retorno
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION ELIMINAR_AULA
	SELECT @MSJ = '[SP_DeleteAulas] - ERROR AL ELIMINAR AULA.'
	RETURN -1
END CATCH

GO

--20.Valores de referencia
CREATE OR ALTER PROCEDURE SET_REFERENCE_VALUES @MATRI DECIMAL(6,2), @ANIO DECIMAL(6,2),
@PERIOD DECIMAL(6,2), @TAX DECIMAL(6,2),@MONTO_MATRICULA DECIMAL(10,2), @MSJ VARCHAR(500) OUT AS

BEGIN TRY
	BEGIN TRANSACTION SET_VALUES
		UPDATE TBL_ReferenceValues SET VALOR = @MATRI WHERE DATO='ActiveEnroll'
		UPDATE TBL_ReferenceValues SET VALOR = @ANIO WHERE DATO='Year'
		UPDATE TBL_ReferenceValues SET VALOR = @PERIOD WHERE DATO='Period'
		UPDATE TBL_ReferenceValues SET VALOR = @TAX WHERE DATO='Tax'
		UPDATE TBL_ReferenceValues SET VALOR = @MONTO_MATRICULA WHERE DATO='CostEnroll'
		SET @MSJ = 'VALORES ACTUALIZADOS'
	COMMIT TRANSACTION SET_VALUES
	RETURN 0
END TRY
BEGIN CATCH
	ROLLBACK TRANSACTION SET_VALUES
	SELECT @MSJ= '[SET_REFERENCE_VALUES] - ERROR AL ACTUALIZAR DATOS.'
	RETURN -999
END CATCH


GO

--21.Borrar materias no matrículadas
CREATE OR ALTER PROCEDURE SP_Delete_Matter @Cod_Materia VARCHAR(6) , @MSJ VARCHAR(200) OUT

AS

DECLARE @vln_Retorno INT = -1 

BEGIN TRY

IF EXISTS(SELECT 1 FROM TBL_Matters WHERE Code = @Cod_Materia)
BEGIN
	IF NOT EXISTS (SELECT 1 FROM TBL_EnrollmentDetails DM INNER JOIN TBL_OpenSubjects MA 
	ON DM.OpenMatCode = MA.OpenSubjectsCode INNER JOIN TBL_CareerMatter MC
	ON MA.CareerMatterCode = MC.CodeCareerMatter INNER JOIN TBL_Matters M
	ON MC.MatterCode = M.Code WHERE M.Code = @Cod_Materia AND DM.DetailStatus = 'MAT')
		BEGIN
			UPDATE TBL_Matters SET Erased = 1 WHERE Code = @Cod_Materia
			SET @MSJ = 'Materia borrada con éxito'
			SET @vln_Retorno = 0
		END
	ELSE
		BEGIN
			SET @MSJ = 'Materia matriculada no se puede borrar'		
		END
END
ELSE
	BEGIN
		SET @MSJ = 'No existe código de materia'
	END
RETURN @vln_Retorno
END TRY
BEGIN CATCH
	SELECT @MSJ = '[SP_Delete_Matter] - ERROR AL BORRAR MATERIA.'
	RETURN -1
END CATCH
GO

--22 Desasignar profesor
CREATE OR ALTER PROCEDURE SP_DESASIGNAR_PROFESOR
@ID_Materia INT, @MSJ VARCHAR(200) OUTPUT

AS

DECLARE @vln_Retorno INT = -1

BEGIN TRY 
	IF EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_Materia
			AND Available = 1)
			BEGIN
				UPDATE TBL_OpenSubjects SET ProfesorCode = NULL WHERE 
				OpenSubjectsCode = @ID_Materia
				SET @vln_Retorno = 0
				SET @MSJ = 'Profesor desasignada'
			END
RETURN @vln_Retorno
END TRY
BEGIN CATCH
	RETURN -1
END CATCH

GO

--23 Desasignar AULA
CREATE OR ALTER PROCEDURE SP_DESASIGNAR_AULA
@ID_Materia INT, @MSJ VARCHAR(200) OUTPUT

AS

DECLARE @vln_Retorno INT = -1

BEGIN TRY 
	IF EXISTS (SELECT 1 FROM TBL_OpenSubjects WHERE OpenSubjectsCode = @ID_Materia
			AND Available = 1)
			BEGIN
				UPDATE TBL_OpenSubjects SET AulaCode = NULL WHERE 
				OpenSubjectsCode = @ID_Materia
				SET @vln_Retorno = 0
				SET @MSJ = 'Aula desasignada'
			END
RETURN @vln_Retorno
END TRY
BEGIN CATCH
	RETURN -1
END CATCH

GO

--24.Facturar matricula
CREATE OR ALTER PROCEDURE SP_FACTURAR_MATRICULA @NUM_FAC INT,
@MSJ VARCHAR(200) OUTPUT

AS

BEGIN TRY
	UPDATE TBL_Enrollments SET StateFac = 'CAN' WHERE NumFact = @NUM_FAC
	RETURN 0
END TRY
BEGIN CATCH
	RETURN -1
END CATCH

GO

--25.Trigger actualizar disponibilidad de materia abierta    
CREATE OR ALTER TRIGGER TR_ACTUALIZAR_MATERIA_ABI ON TBL_EnrollmentDetails
 FOR UPDATE

AS  

IF NOT EXISTS (SELECT 1  
           FROM TBL_EnrollmentDetails ED    
           WHERE ED.DetailStatus = 'MAT' AND OpenMatCode = (SELECT OpenMatCode FROM DELETED))  
BEGIN  
	UPDATE TBL_OpenSubjects SET Available = 0 WHERE OPENSUBJECTSCODE = (SELECT OpenMatCode FROM DELETED)
END
  
GO 
