BEGIN{i=0;j=0;k=0;}
{

	if($1=="==========================")
        {
        printf("%d", $4);
        }

        if($1=="[SUM]")
        {
#        printf(" %.2f\n", $6);
		if($7=="Mbits/sec")
		{
			printf(" %.2f\n", $6);
		}
		else
		{
			printf(" %.2f\n", $7);
		}
        }
}
END{}

