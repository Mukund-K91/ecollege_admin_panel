class SubjectLists {
  static List<String> getSubjects(String program, String programTerm) {
    switch ('$program'+'_'+'$programTerm') {
      case 'BCA_Sem - 1':
        return lists.bca_sem1;
      case 'BCA_Sem - 2':
        return lists.bca_sem2;
      case 'BCA_Sem - 3':
        return lists.bca_sem3;
      case 'BCA_Sem - 4':
        return lists.bca_sem4;
      case 'BCA_Sem - 5':
        return lists.bca_sem5;
      case 'BCA_Sem - 6':
        return lists.bca_sem6;
      case 'BBA_Sem - 1':
        return lists.bba_sem1;
      case 'BBA_Sem - 2':
        return lists.bba_sem2;
      case 'BBA_Sem - 3':
        return lists.bba_sem3;
      case 'BBA_Sem - 4':
        return lists.bba_sem4;
      case 'BBA_Sem - 5':
        return lists.bba_sem5;
      case 'BBA_Sem - 6':
        return lists.bba_sem6;
      case 'B-Com_Sem - 1':
        return lists.b_com_sem1;
      case 'B-Com_Sem - 3':
        return lists.b_com_sem3;
      case 'B-Com_Sem - 5':
        return lists.b_com_sem5;
    // Add more cases for other programs and terms
      default:
        return ["--Please Select--"];
    }
  }
}




class lists {
  static const List<String> programs = [
    "--Please Select--",
    "BCA",
    "B-Com",
    "BBA"
  ];
  static const List<String> programTerms = [
    "--Please Select--",
    "Sem - 1",
    "Sem - 2",
    "Sem - 3",
    "Sem - 4",
    "Sem - 5",
    "Sem - 6"
  ];
  static const List<String> bcaDivision = [
    "--Please Select--",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F"
  ];
  static const List<String> bcomDivision = [
    "--Please Select--",
    "A",
    "B",
    "C",
    "D",
    "E",
    "F",
    "G"
  ];
  static const List<String> bbaDivision = [
    "--Please Select--",
    "A",
    "B",
    "C",
    "D"
  ];

  static const List<String> bca_sem1 = [
    "--Please Select--",
    'COMMUNICATION SKILLS',
    'MATHEMATICS',
    'INTRODUCTION OF COMPUTERS',
    'COMPUTER PROGRAMMING AND PROGRAMMING METHODOLOGY',
    'DATA PROCESSING AND ANALYSIS'
  ];
  static const List<String> bca_sem2 = [
    "--Please Select--",
    'INTRODUCTION TO INTERNET & HTML',
    'EMERGING TRENDS AND IMFORMATION TECHNOLOGY',
    'OPERATING SYSTEM-1',
    'PROGRAMMING SKILLS',
    'CONCEPTS OF RELATIONAL DATABASE MANAGEMENT SYSTEM'
  ];
  static const List<String> bca_sem3 = [
    "--Please Select--",
    'STATISTICAL METHODS',
    'SOFTWARE ENGINEERING',
    'DATABASE HANDLING USING PYTHON',
    'OOP AND DATA STRUCTURES',
    'WEB DESIGNING-1',
    'MOBILE APPLICATION DEVELOPMENT-1',
  ];
  static const List<String> bca_sem4 = [
    "--Please Select--",
    'INFORMATION SYSTEM',
    'INTERNET OF THINGS',
    'JAVA PROGRAMMING',
    '.NET PROGRAMMING',
    'WEB DESIGNING-2',
    'MOBILE APPLICATION DEVELOPMENT-2'
  ];
  static const List<String> bca_sem5 = [
    "--Please Select--",
    'ADVANCED WEB DESIGNING',
    'ADVANCED MOBILE COMPUTING',
    'UNIX AND SHELL PROGRAMMING',
    'NETWORK TECHNOLOGY',
    'WEB FRAMEWORK AND SERVICES',
    'ASP .NET'
  ];
  static const List<String> bca_sem6 = [
    "--Please Select--",
    'FUNDAMENTALS OF CLOUD COMPUTING',
    'E-COMMERCE AND CYBER SECURITY'
  ];

  static const bba_sem1 = [
    "--Please Select--",
    'PRINCIPLES OF MANAGEMENT',
    'ACCCOUNTING FOR MANAGERS',
    'BUSINESS COMMUNICATION',
    'FUNDAMENTELS OF ECONOMICS',
    'COMPUTER SKILLS FOR MANAGERS',
    'GUJARATI',
    'HINDI'
  ];
  static const bba_sem2 = [
    "--Please Select--",
    'ECONOMICS FOR MANAGERS',
    'ORGANISATIONAL BEHAVIOUR',
    'MANAGING MSMES',
    'ENVIRONMENTEL & ECOLOGIC MANAGEMENT',
    'FAMILY BUSINESS MANAGEMENT',
    'LANGUAGE PROFICENCY AND LIFE SKILLS 2',
    'VALUE EDUCATION IN BHAETIYA KNOWLEDGE SYSTEM'
  ];
  static const bba_sem3 = [
    "--Please Select--",
    'ENTERPRENRURSHIP DEVELOPMENT',
    'BUSINESS START-UPS & FINANCIAL SERVICES',
    'MARKETING MANAGEMENT',
    'FINANCIAL MANAGEMENT',
    'HUMAN RESOURCE MANAGEMENT'
  ];
  static const bba_sem4 = [
    "--Please Select--",
    'ETHICS & CORPORATE SOCIAL RESPONSIBILITY',
    'MANAGEMENT OF MSMES',
    'INTRODUCTION TO TAXATION',
    'INTERNATIONAL BUSINESS ENVIRONMENT',
    'PRODUCTION & OPRATIONS MANAGEMENT',
    'QUANTIATIVE TECHNIQUES FOR MANAGEMENT',
  ];
  static const bba_sem5 = [
    "--Please Select--",
    'BUSINESS RESEARCH',
    'SERVICES MANAGEMENT',
    'LEGAL ASPECTS OF BUSINESS',
    'SP-1 ABM AFM HRD',
    'SP2 IMM SFM AHRM'
  ];
  static const bba_sem6 = [
    "--Please Select--",
    'BUSINESS POLICY & STRATEGIC MANAGEMNET',
    'FINACIAL INSTITUTIONS & MARKETS',
    'SPECIALISATION 3',
    'SPECIALISATION 4'
  ];

  static const b_com_sem1 = [
    "--Please Select--",
    'BUSINESS ECONOMICS 1',
    'ENGLISH & PROFICIENCY LIFE SKILLS 1',
    'FINANCIAL ACCOUNTING 1',
    'MODERN BUSINESS PRACTICE 1',
    'ELEMENTS OF BANKING & INSURANCE 1',
    'DESCRIPTIVE STATISTICS 1'
  ];
  static const b_com_sem3 = [
    "--Please Select--",
    'WRITTEN & SPOKEN COMMUNICATION SKILLS-3',
    'MACRO ECONOMICS 3',
    'ACCOUNANCY AND TAXATION 3',
    'BUSINESS ADMINISTRATION 3',
    'ADVANCED ACCOUNTING AND AUDITING 1',
    'ADVANCED ACCOUNTING AND AUDING 2',
    'STATISTICS 3 ',
    'BANKING LAW & PRACTICE'
  ];
  static const b_com_sem5 = [
    "--Please Select--",
    'WRITTEN & SPOKEN COMMUNICATION SKILLS-5',
    'BUSINESS ADMINISTRATION 5',
    'BUSINESS REGULATORY FRAMEWORK 1',
    'INDIAN ECONOMY RECENT TRENDS 5',
    'ADVANCED ACCOUNTING AND AUDITING 5',
    'ADVANCED ACCOUNTING AND AUDITING 6',
    'STATISTICS 7',
    'INDIAN BANKING & CURRENCY SYSTEM 5'
  ];
}
