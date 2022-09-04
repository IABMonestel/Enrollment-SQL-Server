use master
go
--Crear base de datos Matricula
CREATE DATABASE Enrollment2021
go
--Cambiar directorio a base de datos matricula
use Enrollment2021
go
--Crear tabla Careers
CREATE TABLE TBL_Careers(
	Code int identity(1,1) constraint PK_Carrera primary key,
	NameC Varchar(100) not null constraint UQ_NameCareers_Careers UNIQUE,
	Credits smallint not null constraint CK_Credits check (Credits BETWEEN 1 AND 300),
	Degree Varchar(12) not null constraint CK_Degree check( Degree in 
	('Licenciatura','Bachillerato', 'Diplomado','Maestría')) default 'Bachillerato'
	)
--Crear tabla estudiantes
CREATE TABLE TBL_Students(
	License char(6) not null constraint PK_Estudiante primary key,
	Id varchar(20) not null constraint UQ_IdStudent_Students unique,
	NameS varchar(25) not null,
	FLastName varchar(20) not null,
	SLastName varchar(20),
	Phone varchar(8) not null,
	Email varchar(25),
	Province varchar(10) constraint CH_ProStudent check(Province is null or Province in
	('San José','Alajuela','Heredia','Cartago','Guanacaste','Limón','Puntarenas')),
	Canton varchar(25),
	District varchar(25),
	OthersSigns varchar(80),
	AdmissionDate date not null default getDate(),
	Discount tinyInt constraint CK_Discount check(Discount is null or Discount BETWEEN 0 AND 100),
	StateS varchar(3) not null check(StateS in
	('INA','ACT') AND StateS = upper(StateS)) default 'ACT',
	Erased bit not null default 0	
)
--Crear tabla Profesor
CREATE TABLE TBL_Profesors(
	Code int identity(1,1) constraint PK_Profesor primary key,
	Id varchar(15) not null unique,
	NameP varchar(25) not null,
	FLastName varchar(20) not null,
	SLastName varchar(20),
	Phone varchar(8) not null,
	Email varchar(25) not null,
	Erased bit default 0
	)
--Crear tabla Materias
CREATE TABLE TBL_Matters(
	Code varchar(6) constraint PK_Materia primary key,
	NameM varchar(100) not null unique,
	Credits tinyint not null constraint CH_CreditsMatter check (Credits BETWEEN 0 AND 12),
	Erased bit not null default 0
	)
--Crear tabla Aulas
CREATE TABLE TBL_Aulas(
	Codigo smallint identity(1,1) constraint PK_Aula primary key,
	Tipo varchar(11) not null constraint CH_TipoAula check (Tipo in
	('Taller','Laboratorio','Salón')),
	Numero tinyint not null constraint CH_NumeroAula check( Numero > 0),
	Capacidad tinyint not null constraint CH_Capacidad check(Capacidad BETWEEN 1 AND 40)
	)
--Crear tabla Materias_Carreras
CREATE TABLE TBL_CareerMatter(
	CodeCareerMatter int identity(1,1) constraint PK_Mat_Carrera primary key,
	CareerCode int not null,
	constraint FK_CareerCode foreign key (CareerCode) references TBL_Careers (Code),
	MatterCode varchar(6) not null,
	constraint FK_MatterCode foreign key (MatterCode) references TBL_Matters (Code),
	Requirement varchar(6),
	constraint FK_Requirement foreign key (Requirement) references TBL_Matters (Code),
	Corequisite varchar(6),
	constraint FK_Corequisite foreign key (Corequisite) references TBL_Matters (Code),
	Erased bit not null default 0
	)
--Crear tabla Materias_Abiertas
CREATE TABLE TBL_OpenSubjects(
	OpenSubjectsCode int identity(1,1) constraint PK_Mat_Abiertas primary key,
	CareerMatterCode int not null,
	constraint FK_CareerMatterCode foreign key (CareerMatterCode) references TBL_CareerMatter (CodeCareerMatter),
	ProfesorCode int,
	constraint FK_ProfesorCode  foreign key (ProfesorCode ) references TBL_Profesors (Code),
	AulaCode smallint,
	constraint FK_AulaCode foreign key (AulaCode) references TBL_Aulas (Codigo),
	GroupO tinyint,
	Quota tinyint not null default 30,
	Cost decimal(10,2) constraint CH_Cost check(Cost> 0),
	PeriodO tinyint not null constraint CK_Period check (PeriodO BETWEEN 1 AND 3),
	YearO smallint not null constraint CK_Year check(YearO >= Year(getDate())),
	Available bit not null default 1
)
--Crear tabla horarios
CREATE TABLE TBL_Schedule(
	ID int identity(1,1),
	OpenSubjectCode int,
	constraint FK_OpenSubjectCode foreign key (OpenSubjectCode) references TBL_OpenSubjects(OpenSubjectsCode),
	Dia char(1) not null constraint CH_Dia check(Dia in(
		'L','K','M','J','V','S') AND Dia = Upper(Dia)),
	StartTime time not null,
	EndTime time not null,
	constraint PK_Horario primary key(OpenSubjectCode, Dia, StartTime, EndTime)
	)
--Crear tabla Matricula
CREATE TABLE TBL_Enrollments(
	NumFact int identity(1,1) constraint PK_Matricula primary key,
	Meat char(6) not null,
	constraint FK_CarneEstudiante foreign key (Meat) references TBL_Students (License),
	DateM datetime not null constraint DF_Fecha_Matricual default getDate(),
	Amount decimal(10,2) not null constraint CH_Amount check(Amount >0),
	TypePayment varchar(14) constraint CH_TypePayment check(TypePayment in(
	'Efectivo','Sinpe','Transferencia','Tarjeta','Otro')),
	PurchasePayment varchar(15),
	StateFac char(3) not null constraint CH_StateFac check(StateFac in
	('PEN','CAN','ANU') AND StateFac = upper(StateFac)) default 'Pen',
	StateMat char(3) not null constraint CH_StateMat check(StateMat in
	('ACT','INA') AND StateMat = upper(StateMat)) default 'ACT'
	)
--Crear tabla Detalle_Matricula
CREATE TABLE TBL_EnrollmentDetails(
	BillNumber int not null,
	constraint FK_NumFactura foreign key (BillNumber) references TBL_Enrollments(NumFact),
	OpenMatCode int not null,
	constraint FK_CodMatAbiertaDet foreign key (OpenMatCode) references TBL_OpenSubjects(OpenSubjectsCode),
	constraint PK_DetMatricula primary key(BillNumber,OpenMatCode),
	DiscountPercent decimal(5,2) constraint CH_DiscountPercent check(DiscountPercent >= 0) default 0,
	FinalNote decimal(5,2) constraint CH_FinalNote check(FinalNote is null or FinalNote BETWEEN 0 AND 100) default 0,
	DetailStatus char(3) constraint CH_DetailStatus check(DetailStatus in
	('MAT','RET','APR','REP','DST')) default 'MAT'
	)

--Crear tabla de valores por referencia
CREATE TABLE TBL_ReferenceValues(
	ID INT IDENTITY(1,1) PRIMARY KEY,
	DATO VARCHAR(20) NOT NULL,
	VALOR DECIMAL(10,2) NOT NULL
)

INSERT INTO TBL_ReferenceValues(DATO,VALOR)
VALUES('ActiveEnroll',1),('Year',20),('Period',3),('Tax',13),('CostEnroll',1)