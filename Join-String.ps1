# Join-Strings.ps1
function Join-String
{
<#
    .SYNOPSIS
        Joins srings from the pipeline into formatted lines
 
    .DESCRIPTION
        Joins strings from the pipeline into lines of specified character length or item count
		Uses different join character and separators specified by a style name or parameters
 
    .EXAMPLE
        $MyStrings | Join-String
        Splits into multiple lines of 15 items, comma separated
 
    .EXAMPLE
        $MyStrings | Join-String -Style space -ItemsPerLine 6 -pad 20 
        Splits into multiple lines of 6 items per line in columns 20 characters wide

    .EXAMPLE
        $MyStrings | Join-String -Style space6 -pad 20 
        Splits into multiple lines of 6 items per line in columns 20 characters wide
        
    .EXAMPLE
        $MyStrings | Join-String -Style csv -NewLineLength 120
        Splits into multiple lines, comma separated, double quoted, breaking when 120 characters
 
    .EXAMPLE
        $MyStrings | Join-String sql120
        SQL style, breaking after 120 characters  
 
    .PARAMETER Data
        Input strings (or objects) from the pipeline ONLY.   
 
    .PARAMETER Style
       Quick standard formats, default position 0 parameter
          COMMA     : comma separated list   andy,bill,cate, / doris,eugine
          SPACE     : space separated        andy bill cate  / doris eugine
          SPACES    : 3 space separated      andy   bill   cate  / doris   eugine
          PIPE      : pipe separated         andy|bill|cate| / doris|eugine  
          CSV       : double quote, comma    "andy","bill","cate", / "doris","eugine"	  
          SQL       : single quote, comma    'andy','bill','cate', / 'doris','eugine'
          INSERT    : for sql INSERT         ('andy'),('bill'),('cate'), / ('doris'),('eugine')
        A number at the end of the format sets ItemsPerLine (<30) or NewLineLength (30+)
        A zero is all data on one line, ie no linebreaks
 
    .PARAMETER ItemsPerLine
       Number of items to group on each line.

    .PARAMETER NewLineLength
       At this width start a new line.

    .PARAMETER Delimeter
       String to wrap each item, eg quotes. Same both sides.
	   
    .PARAMETER LeftDelim
       Delimiter string, left hand side.  Allows left/right different, eg brackets. 

    .PARAMETER RightDelim
       Delimiter string, right hand side.   Allows left/right different, eg brackets.

    .PARAMETER Pad
       Pad each item with spaces for vertical columns.  This does not truncate, so strings
       longer than the pad length will extend into the next column(s). 

    .NOTES
        Version : 2023-12-20 15:05
        Author  : JimB2
#>
    [CmdletBinding(SupportsShouldProcess=$False,ConfirmImpact='Low')]
    param
    (

        [Parameter(Position=0)]
        [string]$style = 'comma15',

        [Parameter(Mandatory, ValueFromPipeline=$True )]
		[string[]]$data,
        # currently only pipeline input! See this for array input:
        # https://community.spiceworks.com/topic/1026278-passing-array-of-objects-to-a-function


        [int]$ItemsPerLine  = 15,
        [int]$NewLineLength = 0,
        [string]$Separator  = ',',
        [string]$Delimiter  = '',
        [string]$LeftDelim  = '',
        [string]$RightDelim = '',
        [int]$Pad           = 0,
        [switch]$ShowConfig  

    )

    BEGIN
    {   
        #separate the style description and number
        $mode   = $style -replace "[0-9]" , ''
		
        $digits = $style -replace "[^0-9]" , '' 
        		
		switch ( $mode ) {
			'comma'  { break } # use defaults
			'space'  { $Separator = ' ';   break}		
			'spaces' { $Separator = '   '; break}  # three spaces		
			'pipe'   { $Separator = '|';   break}		
			'csv'    { $Separator = ','; $Delimiter = '"'; break}		
			'sql'    { $Separator = ','; $Delimiter = "'"; break}		
			'insert' { $Separator = ','; $LeftDelim ="('"; $RightDelim = "')"; break}		
			default  { Write-Verbose "Unknown style [$style] using default"; break}
		}
		if ( $digits ) {
			$nnn = $digits / 1 # ->int!
        
			if ( $nnn -eq 0 ) {
				# no line breaks
				$ItemsPerLine = $NewLineLength = 0
			}
			elseif ( $nnn -lt 30) {
				$ItemsPerLine  = $nnn
				$NewLineLength = 0
			} else {
				$NewLineLength = $nnn
				$ItemsPerLine  = 0
			}
        }
		# don't count items if line length is specified!
		if ( $length ) { 
            $ItemsPerLine = 0 
        }
		# if single delimeter specified, set both right and left
		if ( $Delimiter ) {
			$LeftDelim = $RightDelim = $Delimiter
		}
        # show config, for debugging etc
        if ( $ShowConfig ) {
            Write-Host "Style <$Style> Mode <$mode>"
            Write-Host "Digits <$digits> nnn <$nnn> ItemsPerLine <$ItemsPerLine> NewLineLength: $NewLineLength>"
            Write-Host "Separator <$Separator> Delimiter <$delimiter> LeftDelim <$LeftDelim> RightDelim <$RightDelim>"
        }
        
        
		# initialise to blank line
		$Line   = ''
		$Count  = 0
    }

    PROCESS
    {
		$count++
		if ( ( $ItemsPerLine -and $Count -gt $ItemsPerLine) -or ( $NewLineLength -and $Line.Length -ge $NewLineLength ) ) {
			# output current line now with separator
            $Line + $Separator
            # reset variables
			$Line   = ''
			$Count  = 1
		} 
		if ( $Line.length ) {
			# add separator if data in the line already
            # and any required padding from last data element
			$Line += $Separator
            # if padding, pad out to count x pad width
            if ( $Pad ) {
                $PadAdd = $Pad * ( $Count - 1) - $Line.Length 
                if ( $PadAdd -gt 0 ) {
                    $line += ' ' * $PadAdd   # Add spaces
                }
            }
		} 
		# add data to line
        $line += $LeftDelim + $data + $RightDelim
    }
    END
    {
		# write out any final partial line, no separator
		if ( $line ) {
            $line
        }
    }
}

# simple test code!
# 'Join-String','is','now', 'loaded' | join-string -style space 
   